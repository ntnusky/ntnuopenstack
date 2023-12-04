# Configures nova's authtoken 
class ntnuopenstack::nova::auth {
  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $www_authenticate_uri = lookup('ntnuopenstack::keystone::auth::uri')
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
    auth_url             => $auth_url,
    memcached_servers    => $memcache,
    password             => $nova_password,
    region_name          => $region,
    www_authenticate_uri => "${public_endpoint}:5000/",
  }

  class { '::nova::keystone::service_user':
    auth_url                => $auth_url,
    password                => $nova_password,
    region_name             => $region,
    send_service_user_token => true,
  }

  class { '::nova::keystone':
    auth_url    => $auth_url,
    password    => $nova_password,
    region_name => $region,
    username    => 'nova',
  }
}
