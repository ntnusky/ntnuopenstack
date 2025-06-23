# Configures heat's authtoken 
class ntnuopenstack::heat::auth {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $www_authenticate_uri = lookup('ntnuopenstack::keystone::auth::uri')
  $region = lookup('ntnuopenstack::region')

  # Retrieve addresses for the memcached servers
  $memcache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[Stdlib::IP::Address],
    'default_value' => [],
  })
  $memcache = $memcache_servers.map | $server | {
    "${server}:11211"
  }

  class { '::heat::keystone::authtoken':
    auth_url                     => $auth_url,
    memcached_servers            => $memcache,
    password                     =>
      $services[$region]['services']['heat']['keystone']['password'],
    region_name                  => $region,
    service_token_roles_required => true,
    username                     =>
      $services[$region]['services']['heat']['keystone']['username'],
    www_authenticate_uri         => $www_authenticate_uri,
  }

  class { '::heat::trustee':
    auth_url => $auth_url,
    username =>
      $services[$region]['services']['heat']['keystone']['username'],
    password =>
      $services[$region]['services']['heat']['keystone']['password'],
  }

  class { '::heat::clients::keystone':
    auth_uri => $www_authenticate_uri,
  }

}
