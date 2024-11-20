# Configures auth for magnum
class ntnuopenstack::magnum::auth {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })
  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $region_name = lookup('ntnuopenstack::region')
  $www_authenticate_uri = lookup('ntnuopenstack::keystone::auth::uri')

  $memcache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[Stdlib::IP::Address],
    'default_value' => [],
  })
  $memcache = $memcache_servers.map | $server | {
    "${server}:11211"
  }

  class { '::magnum::keystone::authtoken':
    auth_url             => $auth_url,
    memcached_servers    => $memcache,
    password             =>
      $services[$region_name]['services']['magnum']['keystone']['password'],
    region_name          => $region_name,
    username             =>
      $services[$region_name]['services']['magnum']['keystone']['username'],
    www_authenticate_uri => "${www_authenticate_uri}v3",
  }

  class { '::magnum::keystone::keystone_auth':
    auth_url => $auth_url,
    password =>
      $services[$region_name]['services']['magnum']['keystone']['password'],
    username =>
      $services[$region_name]['services']['magnum']['keystone']['username'],
  }
}
