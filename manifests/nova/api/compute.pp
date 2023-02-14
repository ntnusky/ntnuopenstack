# Installs and configures the nova compute API.
class ntnuopenstack::nova::api::compute {
  # Retrieve addresses for the memcached servers
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

  $use_keystone_limits = lookup('ntnuopenstack::glance::keystone::limits', {
    'default_value' => false,
    'value_type'    => Boolean,
  })

  $internal_endpoint = lookup('ntnuopenstack::endpoint::internal')
  $public_endpoint = lookup('ntnuopenstack::endpoint::public')

  include ::ntnuopenstack::nova::common::neutron
  contain ::ntnuopenstack::nova::firewall::server
  contain ::ntnuopenstack::nova::haproxy::backend::api
  include ::ntnuopenstack::nova::munin::api
  include ::ntnuopenstack::nova::quota
  require ::ntnuopenstack::nova::services::base
  require ::ntnuopenstack::repo

  class { '::nova::api':
    enabled                      => false,
    enable_proxy_headers_parsing => true,
    nova_metadata_wsgi_enabled   => true,
    service_name                 => 'httpd',
    sync_db                      => $sync_db,
    sync_db_api                  => $sync_db,
    use_forwarded_for            => true,
  }

  class { '::nova::keystone':
    auth_url    => "${internal_endpoint}:5000/",
    password    => $nova_password,
    region_name => $region,
    username    => 'nova',
  }

  class { '::nova::keystone::authtoken':
    auth_url             => "${internal_endpoint}:5000/",
    memcached_servers    => $memcache,
    password             => $nova_password,
    region_name          => $region,
    www_authenticate_uri => "${public_endpoint}:5000/",
  }

  class { '::nova::wsgi::apache_api':
    ssl               => false,
    access_log_format => 'forwarded',
  }

}
