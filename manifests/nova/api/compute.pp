# Installs and configures the nova compute API.
class ntnuopenstack::nova::api::compute {
  # Retrieve addresses for the memcached servers, either the old IP or the new
  # list of hosts.
  $memcache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[Stdlib::IP::Address],
    'default_value' => [],
  })
  $memcache = $memcache_servers.map | $server | {
    "${server}:11211"
  }

  # Retrieve openstack parameters
  $nova_password = lookup('ntnuopenstack::nova::keystone::password')
  $sync_db = lookup('ntnuopenstack::nova::db::sync', {
    'value_type'    => Boolean,
    'default_value' => false,   # One of your nodes need to have this key set to
                                # true to automaticly populate the databases.
  })
  $region = lookup('ntnuopenstack::region')

  $admin_endpoint    = lookup('ntnuopenstack::endpoint::admin')
  $internal_endpoint = lookup('ntnuopenstack::endpoint::internal')

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::nova::base
  contain ::ntnuopenstack::nova::firewall::server
  include ::ntnuopenstack::nova::munin::api
  include ::ntnuopenstack::nova::neutron

  contain ::ntnuopenstack::nova::haproxy::backend::api

  class { '::nova::keystone::authtoken':
    auth_url             => "${admin_endpoint}:35357/",
    www_authenticate_uri => "${internal_endpoint}:5000/",
    password             => $nova_password,
    memcached_servers    => $memcache,
    region_name          => $region,
  }

  class { '::nova::api':
    enabled                      => false,
    enable_proxy_headers_parsing => true,
    nova_metadata_wsgi_enabled   => true,
    service_name                 => 'httpd',
    sync_db                      => $sync_db,
    sync_db_api                  => $sync_db,
    use_forwarded_for            => true,
  }

  class { '::nova::wsgi::apache_api':
    ssl               => false,
    access_log_format => 'forwarded',
  }
}
