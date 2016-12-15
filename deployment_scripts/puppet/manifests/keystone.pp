notice('MODULAR: congress/keystone.pp')

$plugin_hash = hiera_hash('congress', {})
$congress_hash = $plugin_hash['metadata']
$port = $congress_hash['port']

$public_vip          = hiera('public_vip')
$public_ssl_hash     = hiera_hash('public_ssl')
$management_vip      = hiera('management_vip')
$region              = pick($congress_hash['region'], hiera('region', 'RegionOne'))
$password            = $congress_hash['user_password']
$auth_name           = pick($congress_hash['auth_name'], 'congress')
$configure_endpoint  = pick($congress_hash['configure_endpoint'], true)
$configure_user      = pick($congress_hash['configure_user'], true)
$configure_user_role = pick($congress_hash['configure_user_role'], true)
$service_name        = pick($congress_hash['service_name'], 'congress')
$tenant              = pick($congress_hash['tenant'], 'services')
$ssl_hash            = hiera_hash('use_ssl', {})

Class['::osnailyfacter::wait_for_keystone_backends'] -> Class['::congress::keystone::auth']

$public_protocol     = get_ssl_property($ssl_hash, $public_ssl_hash, 'congress', 'public', 'protocol', 'http')
$public_address      = get_ssl_property($ssl_hash, $public_ssl_hash, 'congress', 'public', 'hostname', [$public_vip])
$internal_protocol   = get_ssl_property($ssl_hash, {}, 'congress', 'internal', 'protocol', 'http')
$internal_address    = get_ssl_property($ssl_hash, {}, 'congress', 'internal', 'hostname', [$management_vip])
$admin_protocol      = get_ssl_property($ssl_hash, {}, 'congress', 'admin', 'protocol', 'http')
$admin_address       = get_ssl_property($ssl_hash, {}, 'congress', 'admin', 'hostname', [$management_vip])

$public_url   = "${public_protocol}://${public_address}:${port}"
$internal_url = "${internal_protocol}://${internal_address}:${port}"
$admin_url    = "${admin_protocol}://${admin_address}:${port}"

validate_string($public_address)
validate_string($password)

class {'::osnailyfacter::wait_for_keystone_backends':}

class { 'congress::keystone::auth':
  auth_name           => $auth_name,
  password            => $password,
  tenant              => $tenant,
  admin_url           => $admin_url,
  internal_url        => $internal_url,
  public_url          => $public_url,
  region              => $region,
}