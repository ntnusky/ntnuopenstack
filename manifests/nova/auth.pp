# Configures nova's authtoken 
class ntnuopenstack::nova::auth {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $www_authenticate_uri = lookup('ntnuopenstack::keystone::auth::uri')
  $region = lookup('ntnuopenstack::region', String)
  $memcache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[Stdlib::IP::Address],
    'default_value' => [],
  })
  $memcache = $memcache_servers.map | $server | {
    "${server}:11211"
  }

  class { '::nova::keystone::authtoken':
    auth_url                     => $auth_url,
    memcached_servers            => $memcache,
    password                     =>
      $services[$region]['services']['nova']['keystone']['password'],
    region_name                  => $region,
    service_token_roles_required => true,
    service_type                 => 'compute',
    username                     =>
      $services[$region]['services']['nova']['keystone']['username'],
    www_authenticate_uri         => $www_authenticate_uri,
  }

  class { '::nova::keystone::service_user':
    auth_url                => $auth_url,
    password                =>
      $services[$region]['services']['nova']['keystone']['password'],
    region_name             => $region,
    send_service_user_token => true,
    username                =>
      $services[$region]['services']['nova']['keystone']['username'],
  }

  class { '::nova::keystone':
    auth_url    => $auth_url,
    password    =>
      $services[$region]['services']['nova']['keystone']['password'],
    region_name => $region,
    username    =>
      $services[$region]['services']['nova']['keystone']['username'],
  }
}
