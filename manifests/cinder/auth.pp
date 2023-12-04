# Configures the base cinder config
class ntnuopenstack::cinder::auth {
  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $password = lookup('ntnuopenstack::cinder::keystone::password')
  $region_name = lookup('ntnuopenstack::region')
  $www_authenticate_uri = lookup('ntnuopenstack::keystone::auth::uri')

  $memcache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[Stdlib::IP::Address],
    'default_value' => [],
  })
  $memcache = $memcache_servers.map | $server | {
    "${server}:11211"
  }

  class { '::cinder::keystone::authtoken':
    auth_url             => $auth_url,
    memcached_servers    => $memcache,
    password             => $password,
    region_name          => $region_name,
    www_authenticate_uri => $www_authenticate_uri,
  }

  class { '::cinder::keystone::service_user':
    auth_url                => $auth_url,
    password                => $password,
    region_name             => $region_name,
    send_service_user_token => true,
  }
}
