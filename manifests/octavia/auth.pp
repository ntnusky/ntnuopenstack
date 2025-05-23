# This class configures the keystone authentication for octavia
class ntnuopenstack::octavia::auth {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $www_authenticate_uri = lookup('ntnuopenstack::keystone::auth::uri')
  $region = lookup('ntnuopenstack::region')

  $cache_servers = lookup('profile::memcache::servers', {
    'value_type' => Array[Stdlib::IP::Address],
    'merge'      => 'unique',
  })
  $memcache = $cache_servers.map | $server | {
    "${server}:11211"
  }

  class { '::octavia::keystone::authtoken':
    auth_url             => $auth_url,
    memcached_servers    => $memcache, 
    password             => 
      $services[$region]['services']['octavia']['keystone']['password'],
    region_name          => $region,
    username             => 
      $services[$region]['services']['octavia']['keystone']['username'],
    www_authenticate_uri => $www_authenticate_uri,
  }

  class { '::octavia::service_auth':
    auth_url             => $auth_url,
    password             => 
      $services[$region]['services']['octavia']['keystone']['password'],
    username             => 
      $services[$region]['services']['octavia']['keystone']['username'],
    project_name        => 'services',
    user_domain_name    => 'default',
    project_domain_name => 'default',
    auth_type           => 'password',
  }
  class { '::octavia::neutron':
    auth_url   => $auth_url,
    password   => 
      $services[$region]['services']['octavia']['keystone']['password'],
    region_name => $region, 
    username   => 
      $services[$region]['services']['octavia']['keystone']['username'],
  }
}
