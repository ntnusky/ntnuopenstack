# Configures a typical authtoken-section for a service. 
define ntnuopenstack::common::authtoken {
  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $www_authenticate_uri = lookup('ntnuopenstack::keystone::auth::uri')
  $password = lookup("ntnuopenstack::${name}::keystone::password")
  $region_name = lookup('ntnuopenstack::region')

  $memcache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[Stdlib::IP::Address],
    'default_value' => [],
  })
  $memcache = $memcache_servers.map | $server | {
    "${server}:11211"
  }

  include "::${name}::deps"

  class { "::${name}::keystone::authtoken":
    auth_url             => $auth_url,
    memcached_servers    => $memcache, 
    password             => $password,
    region_name          => $region_name,
    www_authenticate_uri => $www_authenticate_uri,
    before               => Anchor["::${name}::config::begin"],
  }
}
