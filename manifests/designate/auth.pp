# This class configures the keystone authentication for designate
class ntnuopenstack::designate::auth {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  $cache_servers = lookup('profile::memcache::servers', {
    'value_type' => Array[Stdlib::IP::Address],
    'merge'      => 'unique',
  })

  $memcache = $cache_servers.map | $server | {
    "${server}:11211"
  }

  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $www_authenticate_uri = lookup('ntnuopenstack::keystone::auth::uri')

  $region = lookup('ntnuopenstack::region', String)

  class { '::designate::keystone::authtoken':
    auth_url             => $auth_url,
    memcached_servers    => $memcache,
    password             =>
      $services[$region]['services']['designate']['keystone']['password'],
    region_name          => $region,
    username             =>
      $services[$region]['services']['designate']['keystone']['username'],
    www_authenticate_uri => $www_authenticate_uri, 
  }
}
