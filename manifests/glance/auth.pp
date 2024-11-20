# Configures auth for the glance service. 
class ntnuopenstack::glance::auth {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $www_authenticate_uri = lookup('ntnuopenstack::keystone::auth::uri')
  $region = lookup('ntnuopenstack::region', String)
  $cache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[String],
    'merge'         => 'unique',
  })
  $memcache = $cache_servers.map | $server | {
    "${server}:11211"
  }

  class { '::glance::api::authtoken':
    auth_url             => $auth_url, 
    memcached_servers    => $memcache,
    password             =>
      $services[$region]['services']['glance']['keystone']['password'],
    region_name          => $region,
    username             =>
      $services[$region]['services']['glance']['keystone']['username'],
    www_authenticate_uri => $www_authenticate_uri, 
  }
}
