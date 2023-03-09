# Configures auth for magnum
class ntnuopenstack::magnum::auth {
  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $password = lookup('ntnuopenstack::magnum::keystone::password')
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
    password             => $password,
    region_name          => $region_name,
    www_authenticate_uri => "${www_authenticate_uri}v3",
  }

  class { '::magnum::keystone::keystone_auth':
    auth_url => $auth_url,
    password => $password,
  }
}
