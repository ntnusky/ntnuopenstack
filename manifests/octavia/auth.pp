# This class configures the keystone authentication for octavia
class ntnuopenstack::octavia::auth {
  $cache_servers = lookup('profile::memcache::servers', {
    'value_type' => Array[Stdlib::IP::Address],
    'merge'      => 'unique',
  })
  $memcache = $cache_servers.map | $server | {
    "${server}:11211"
  }

  $keystone_password = lookup('ntnuopenstack::octavia::keystone::password')
  $keystone_internal = lookup('ntnuopenstack::keystone::endpoint::internal',
      Stdlib::Httpurl)
  $keystone_public = lookup('ntnuopenstack::keystone::endpoint::public', 
      Stdlib::Httpurl)
  $region = lookup('ntnuopenstack::region', String)

  class { '::octavia::keystone::authtoken':
    auth_url             => "${keystone_internal}:5000/",
    memcached_servers    => $memcache,
    password             => $keystone_password,
    region_name          => $region,
    www_authenticate_uri => "${keystone_public}:5000/",
  }

  class { '::octavia::service_auth':
    auth_url            => "${keystone_internal}:5000/v3",
    username            => 'octavia',
    project_name        => 'services',
    password            => $keystone_password,
    user_domain_name    => 'default',
    project_domain_name => 'default',
    auth_type           => 'password',
  }
}
