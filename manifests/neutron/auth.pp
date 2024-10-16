# Configures auth for neutron 
class ntnuopenstack::neutron::auth {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $www_authenticate_uri = lookup('ntnuopenstack::keystone::auth::uri')
  $region = lookup('ntnuopenstack::region', String)
  $cache_servers = lookup('profile::memcache::servers', {
    'value_type' => Array[Stdlib::IP::Address],
    'merge'      => 'unique',
  })
  $memcache = $cache_servers.map | $server | {
    "${server}:11211"
  }

  include ::neutron::server::notifications

  class { '::neutron::keystone::authtoken':
    auth_url             => $auth_url, 
    memcached_servers    => $memcache,
    password             =>
      $services[$region]['services']['neutron']['keystone']['password'],
    region_name          => $region,
    username             =>
      $services[$region]['services']['neutron']['keystone']['username'],
    www_authenticate_uri => $www_authenticate_uri, 
  }

  class { '::neutron::server::notifications::nova':
    auth_url     => $auth_url, 
    password     =>
      $services[$region_name]['services']['nova']['keystone']['password'],
    region_name  => $region,
  }
}
