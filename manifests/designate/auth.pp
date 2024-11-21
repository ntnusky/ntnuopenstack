# This class configures the keystone authentication for designate
class ntnuopenstack::designate::auth {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  $cache_servers = lookup('profile::memcache::servers', {
    'value_type' => Array[Stdlib::IP::Address],
    'merge'      => 'unique',
  })

  $memcache = $cache_servers.map | $server | {
    "${server}:11211"
  }

  $keystone_admin = lookup('ntnuopenstack::keystone::endpoint::admin',
      Stdlib::Httpurl)
  $keystone_internal = lookup('ntnuopenstack::keystone::endpoint::internal',
      Stdlib::Httpurl)
  $keystone_public = lookup('ntnuopenstack::keystone::endpoint::public',
      Stdlib::Httpurl)
  $region = lookup('ntnuopenstack::region', String)

  class { '::designate::keystone::authtoken':
    auth_url             => "${keystone_internal}:5000/",
    memcached_servers    => $memcache,
    password             =>
      $services[$region]['services']['designate']['keystone']['password'],
    region_name          => $region,
    username             =>
      $services[$region]['services']['designate']['keystone']['username'],
    www_authenticate_uri => "${keystone_public}:5000/",
  }
}
