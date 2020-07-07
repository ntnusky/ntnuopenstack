# Creates the databases for the placement service.
class ntnuopenstack::placement::api {
  $confhaproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'value_type'    => Boolean,
    'default_value' => true,
  })
  $db_sync = lookup('ntnuopenstack::placement::db::sync̈́', Boolean)

  include ::ntnuopenstack::placement::firewall::server
  include ::ntnuopenstack::placement::haproxy::backend

  if($confhaproxy) {
    contain ::ntnuopenstack::placement::haproxy::backend
    $logformat = 'forwarded'
  } else {
    $logformat = false
  }

  class { '::placement':
    sync_db => $db_sync,
  }

  class { '::placement::keystone::authtoken':
    password             => $keystone_password,
    auth_url             => "${keystone_internal}:5000",
    www_authenticate_uri => "${keystone_public}:5000",
    memcached_servers    => $memcache,
    region_name          => $region,
  }

  class { '::placement::wsgi::apache':
    api_port          => 8778,
    ssl               => false,
    access_log_format => $logformat,
  }
}
