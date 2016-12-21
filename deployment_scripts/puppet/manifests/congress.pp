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


class { 'congress':
  rabbit_hosts        => $rabbit_hosts,
  rabbit_password     => $rabbit_password,
  rabbit_userid       => $rabbit_userid
}

include congress::client
