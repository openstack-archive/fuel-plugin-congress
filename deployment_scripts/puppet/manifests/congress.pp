notice('MODULAR: congress.pp')

$management_vip = hiera('management_vip')
$public_vip     = hiera('public_vip')

$plugin_hash = hiera_hash('congress', {})
$debug       = $plugin_hash['debug']
$congress_hash = $plugin_hash['metadata']

$rabbit_hash        = hiera_hash('rabbit', {})
$rabbit_hosts       = split(hiera('amqp_hosts',''), ',')
$rabbit_password    = $rabbit_hash['password']
$rabbit_userid      = $rabbit_hash['user']

$database_vip = hiera('database_vip', undef)
$db_type      = 'mysql'
$db_host      = pick($congress_hash['db_host'], $database_vip)
$db_user      = pick($congress_hash['username'], 'congress')
$db_password  = $congress_hash['db_password']
$db_name      = pick($congress_hash['db_name'], 'congress')

$db_connection = os_database_connection({
  'dialect'  => $db_type,
  'host'     => $db_host,
  'database' => $db_name,
  'username' => $db_user,
  'password' => $db_password,
  'charset'  => 'utf8'
})

class {'congress::db':
  database_connection => $db_connection,
}

class { 'congress':
  rabbit_hosts        => $rabbit_hosts,
  rabbit_password     => $rabbit_password,
  rabbit_userid       => $rabbit_userid
}

include congress::client
