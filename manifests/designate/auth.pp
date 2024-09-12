# This class configures the keystone authentication for designate
class ntnuopenstack::designate::auth {
  $cache_servers = lookup('profile::memcache::servers', {
    'value_type' => Array[Stdlib::IP::Address],
    'merge'      => 'unique',
  })
  $memcache = $cache_servers.map | $server | {
    "${server}:11211"
  }

  $keystone_password = lookup('ntnuopenstack::designate::keystone::password')
  $keystone_internal = lookup('ntnuopenstack::keystone::endpoint::internal',
      Stdlib::Httpurl)
  $keystone_public = lookup('ntnuopenstack::keystone::endpoint::public',
      Stdlib::Httpurl)
  $region = lookup('ntnuopenstack::region', String)

  class { '::designate::keystone::authtoken':
    auth_url             => "${keystone_internal}:5000/",
    memcached_servers    => $memcache,
    password             => $keystone_password,
    region_name          => $region,
    www_authenticate_uri => "${keystone_public}:5000/",
  }
}
