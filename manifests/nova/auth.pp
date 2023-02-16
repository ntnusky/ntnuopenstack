# Configures nova's authtoken 
class ntnuopenstack::nova::auth {
  $public_endpoint = lookup('ntnuopenstack::endpoint::public')
  $internal_endpoint = lookup('ntnuopenstack::endpoint::internal')
  $nova_password = lookup('ntnuopenstack::nova::keystone::password')
  $region = lookup('ntnuopenstack::region')

  # Retrieve addresses for the memcached servers
  $memcache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[Stdlib::IP::Address],
    'default_value' => [],
  })
  $memcache = $memcache_servers.map | $server | {
    "${server}:11211"
  }

  class { '::nova::keystone::authtoken':
    auth_url             => "${internal_endpoint}:5000/",
    memcached_servers    => $memcache,
    password             => $nova_password,
    region_name          => $region,
    www_authenticate_uri => "${public_endpoint}:5000/",
  }

  class { '::nova::keystone':
    auth_url    => "${internal_endpoint}:5000/",
    password    => $nova_password,
    region_name => $region,
    username    => 'nova',
  }
}
