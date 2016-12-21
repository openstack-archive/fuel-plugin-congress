notice('MODULAR: congress/server.pp')

$management_vip = hiera('management_vip')
$public_vip     = hiera('public_vip')
$network_scheme = hiera_hash('network_scheme', {})
prepare_network_config($network_scheme)

$plugin_hash = hiera_hash('congress', {})
$congress_hash = $plugin_hash['metadata']

$bind_port    = $congress_hash['port']
$bind_host    = get_network_role_property('management', 'ipaddr')
$service_name = pick($congress_hash['service'], 'congress-server')

$service_enabled  = $plugin_hash['enabled']
$policies         = parsejson($plugin_hash['policies'], {})

$congress_tenant        = pick($congress_hash['tenant'], 'services')
$congress_user          = pick($congress_hash['user'], 'congress')
$congress_user_password = $congress_hash['user_password']

$ssl_hash               = hiera_hash('use_ssl', {})
$public_auth_protocol   = get_ssl_property($ssl_hash, {}, 'keystone', 'public', 'protocol', 'http')
$public_auth_address    = get_ssl_property($ssl_hash, {}, 'keystone', 'public', 'hostname', $public_vip)
$admin_auth_protocol    = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'protocol', 'http')
$admin_auth_address     = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'hostname', $management_vip)

$auth_uri     = "${public_auth_protocol}://${public_auth_address}:5000"
$auth_url = "${admin_auth_protocol}://${admin_auth_address}:35357"


class { 'congress::keystone::authtoken':
  password            => $congress_user_password,
  username            => $congress_user,
  project_name        => $congress_tenant,
  auth_url            => $auth_url,
  auth_uri            => $auth_uri,

}

class {'congress::policy':
  policies            => $policies
}

class {'congress::server':
  enabled             => $service_enabled,
  bind_host           => $bind_host,
  bind_port           => $bind_port
}
