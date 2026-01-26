# Configures the base cinder config
class ntnuopenstack::cinder::auth {
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

  class { '::cinder::keystone::authtoken':
    auth_url                     => $auth_url,
    memcached_servers            => $memcache,
    password                     =>
      $services[$region_name]['services']['cinder']['keystone']['password'],
    region_name                  => $region_name,
    service_token_roles_required => true,
    service_type                 => 'volumev3',
    username                     =>
      $services[$region_name]['services']['cinder']['keystone']['username'],
    www_authenticate_uri         => $www_authenticate_uri,
  }

  class { '::cinder::keystone::service_user':
    auth_url                => $auth_url,
    password                =>
      $services[$region_name]['services']['cinder']['keystone']['password'],
    region_name             => $region_name,
    send_service_user_token => true,
    username                =>
      $services[$region_name]['services']['cinder']['keystone']['username'],
  }

  openstacklib::clouds { '/etc/openstack/puppet/admin-clouds.yaml':
    username     =>
      $services[$region_name]['services']['cinder']['keystone']['username'],
    password     =>
      $services[$region_name]['services']['cinder']['keystone']['password'],
    auth_url     => $auth_url,
    project_name => 'services',
    system_scope => 'all',
    region_name  => $region_name,
    interface    => 'internal',
  }
}
