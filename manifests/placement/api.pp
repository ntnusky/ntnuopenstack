# Installs and configures Placement API
class ntnuopenstack::placement::api {
  # Retrieve openstack-settings
  $region = lookup('ntnuopenstack::region', String)
  $keystone_password = lookup('ntnuopenstack::placement::keystone::password',
                                String)
  $keystone_internal = lookup('ntnuopenstack::keystone::endpoint::internal',
                                Stdlib::Httpurl)
  $keystone_public = lookup('ntnuopenstack::keystone::endpoint::public',
                                Stdlib::Httpurl)
  $db_sync = lookup('ntnuopenstack::placement::db::sync', Boolean)

  # Retrieve addresses for the memcached servers
  $cache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[String],
    'merge'         => 'unique',
  })
  $memcache = $cache_servers.map | $server | {
    "${server}:11211"
  }

  # Determining if the server is placed behind haproxy
  $confhaproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  require ::ntnuopenstack::repo
  include ::ntnuopenstack::placement::dbconnection
  include ::ntnuopenstack::placement::firewall::server
  # Placement logs all activity through apache-logs.
  include ::profile::services::apache::logging

  if($confhaproxy) {
    contain ::ntnuopenstack::placement::haproxy::backend
    $logformat = 'forwarded'
  } else {
    $logformat = false
  }

  class { '::placement':
    sync_db => $db_sync,
  }

  class { '::placement::api':
    api_service_name             => 'httpd',
    enable_proxy_headers_parsing => $confhaproxy,
    sync_db                      => $db_sync,
  }

  class { '::placement::keystone::authtoken':
    auth_url                     => "${keystone_internal}:5000",
    memcached_servers            => $memcache,
    password                     => $keystone_password,
    region_name                  => $region,
    service_token_roles          => [ 'admin', 'service' ],
    service_token_roles_required => true,
    www_authenticate_uri         => "${keystone_public}:5000",
  }

  class { '::placement::wsgi::apache':
    access_log_format => $logformat,
    api_port          => 8778,
    path              => '/placement',
    ssl               => false,
  }
}
