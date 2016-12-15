notice('MODULAR: congress/db.pp')

$plugin_hash    = hiera_hash('congress', {})
$congress_hash    = $plugin_hash['metadata']
$mysql_hash     = hiera_hash('mysql', {})
$management_vip = hiera('management_vip')
$database_vip   = hiera('database_vip')

$mysql_root_user     = pick($mysql_hash['root_user'], 'root')
$mysql_root_password = $mysql_hash['root_password']

$db_user     = pick($congress_hash['user'], 'congress')
$db_name     = pick($congress_hash['db_name'], 'congress')
$db_password = pick($congress_hash['db_password'], $mysql_root_password)

$db_host          = $database_vip
$db_root_user     = $mysql_root_user
$db_root_password = $mysql_root_password

$allowed_hosts = [ 'localhost', '127.0.0.1', '%' ]

validate_string($mysql_root_user)
validate_string($database_vip)

class { '::openstack::galera::client':
  custom_setup_class => hiera('mysql_custom_setup_class', 'galera'),
}

class { '::congress::db::mysql':
  user          => $db_user,
  password      => $db_password,
  dbname        => $db_name,
  allowed_hosts => $allowed_hosts,
}

class { '::osnailyfacter::mysql_access':
  db_host     => $db_host,
  db_user     => $db_root_user,
  db_password => $db_root_password,
}

Class['::openstack::galera::client'] ->
  Class['::osnailyfacter::mysql_access'] ->
  Class['::tacker::db::mysql']

class mysql::config {}
include mysql::config
class mysql::server {}
include mysql::server