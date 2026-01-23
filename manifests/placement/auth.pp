# Installs and configures Placement Auth
class ntnuopenstack::placement::auth {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $www_authenticate_uri = lookup('ntnuopenstack::keystone::auth::uri')
  $region_name = lookup('ntnuopenstack::region')
  $memcache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[Stdlib::IP::Address],
    'default_value' => [],
  })
  $memcache = $memcache_servers.map | $server | {
    "${server}:11211"
  }

  class { '::placement::keystone::authtoken':
    auth_url                     => $auth_url, 
    memcached_servers            => $memcache,
    password                     =>
      $services[$region_name]['services']['placement']['keystone']['password'],
    region_name                  => $region_name,
    service_token_roles          => [ 'admin', 'service' ],
    service_token_roles_required => true,
    service_type                 => 'placement',
    username                     =>
      $services[$region_name]['services']['placement']['keystone']['username'],
    www_authenticate_uri         => $www_authenticate_uri 
  }
}
