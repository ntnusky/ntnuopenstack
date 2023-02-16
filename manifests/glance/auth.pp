# Configures auth for the glance service. 
class ntnuopenstack::glance::auth {
  # Retrieve addresses for the memcached servers
  $cache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[String],
    'merge'         => 'unique',
  })
  $memcache = $cache_servers.map | $server | {
    "${server}:11211"
  }

  # Determine where the keystone service is located.
  $keystone_internal = lookup('ntnuopenstack::keystone::endpoint::internal', 
      Stdlib::Httpurl)
  $keystone_public = lookup('ntnuopenstack::keystone::endpoint::public', 
      Stdlib::Httpurl)
  $keystone_password = lookup('ntnuopenstack::glance::keystone::password', 
      String)
  $region = lookup('ntnuopenstack::region', String)

  class { '::glance::api::authtoken':
    auth_url             => "${keystone_internal}:5000",
    memcached_servers    => $memcache,
    password             => $keystone_password,
    region_name          => $region,
    www_authenticate_uri => "${keystone_public}:5000",
  }
}
