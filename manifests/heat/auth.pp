# Configures heat's authtoken 
class ntnuopenstack::heat::auth {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  $public_endpoint = lookup('ntnuopenstack::endpoint::public')
  $internal_endpoint = lookup('ntnuopenstack::endpoint::internal')
  $region = lookup('ntnuopenstack::region')

  # Retrieve addresses for the memcached servers
  $memcache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[Stdlib::IP::Address],
    'default_value' => [],
  })
  $memcache = $memcache_servers.map | $server | {
    "${server}:11211"
  }

  class { '::heat::keystone::authtoken':
    auth_url             => "${internal_endpoint}:5000/",
    memcached_servers    => $memcache,
    password             => 
      $services[$region]['services']['heat']['keystone']['password'],
    region_name          => $region,
    username             => 
      $services[$region]['services']['heat']['keystone']['username'],
    www_authenticate_uri => "${public_endpoint}:5000/v3",
  }

  class { '::heat::trustee':
    auth_url => "${internal_endpoint}:5000/",
    username             => 
      $services[$region]['services']['heat']['keystone']['username'],
    password => 
      $services[$region]['services']['heat']['keystone']['password'],
  }

}
