# Configures auth for neutron 
class ntnuopenstack::neutron::auth {
  $cache_servers = lookup('profile::memcache::servers', {
    'value_type' => Array[Stdlib::IP::Address],
    'merge'      => 'unique',
  })
  $memcache = $cache_servers.map | $server | {
    "${server}:11211"
  }

  $keystone_admin = lookup('ntnuopenstack::keystone::endpoint::admin', 
      Stdlib::Httpurl)
  $keystone_public = lookup('ntnuopenstack::keystone::endpoint::public', 
      Stdlib::Httpurl)
  $neutron_password = lookup('ntnuopenstack::neutron::keystone::password', 
      String)
  $nova_password = lookup('ntnuopenstack::nova::keystone::password', String)
  $region = lookup('ntnuopenstack::region', String)

  include ::neutron::server::notifications

  class { '::neutron::keystone::authtoken':
    auth_url             => "${keystone_admin}:5000/",
    memcached_servers    => $memcache,
    password             => $neutron_password,
    region_name          => $region,
    www_authenticate_uri => "${keystone_public}:5000/",
  }

  class { '::neutron::server::notifications::nova':
    auth_url     => "${keystone_admin}:5000",
    password     => $nova_password,
    region_name  => $region,
  }
}
