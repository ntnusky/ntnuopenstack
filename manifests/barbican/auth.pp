# Configures auth for barbican. 
class ntnuopenstack::barbican::auth {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $www_authenticate_uri = lookup('ntnuopenstack::keystone::auth::uri')
  $region = lookup('ntnuopenstack::region')

  $memcache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[Stdlib::IP::Address],
    'default_value' => [],
  })
  $memcache = $memcache_servers.map | $server | {
    "${server}:11211"
  }

  class { '::barbican::keystone::authtoken':
    auth_url             => $auth_url,
    memcached_servers    => $memcache, 
    password             => 
      $services[$region]['services']['barbican']['keystone']['password'],
    region_name          => $region,
    username             => 
      $services[$region]['services']['barbican']['keystone']['username'],
    www_authenticate_uri => $www_authenticate_uri,
  }
}
