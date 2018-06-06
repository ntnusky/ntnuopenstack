# Installs and configures the nova compute API.
class ntnuopenstack::nova::api::compute {
  # Retrieve addresses for the memcached servers, either the old IP or the new
  # list of hosts.
  $memcached_ip = hiera('profile::memcache::ip', undef)
  $memcache_servers = hiera_array('profile::memcache::servers', undef)
  $memcache_servers_real = pick($memcache_servers, [$memcached_ip])
  $memcache = $memcache_servers_real.map | $server | {
    "${server}:11211"
  }

  # Determine if haproxy or keepalived should be configured
  $confhaproxy = hiera('ntnuopenstack::haproxy::configure::backend', true)
  $nova_admin_ip = hiera('profile::api::nova::admin::ip', false)

  # Retrieve openstack parameters
  $nova_password = hiera('ntnuopenstack::nova::keystone::password')
  $nova_secret = hiera('ntnuopenstack::nova::sharedmetadataproxysecret')
  $sync_db = hiera('ntnuopenstack::nova::sync_db')
  $region = hiera('ntnuopenstack::region')

  # Determine the keystone endpoint.
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip', '127.0.0.1')
  $admin_endpoint    = hiera('ntnuopenstack::endpoint::admin', undef)
  $internal_endpoint = hiera('ntnuopenstack::endpoint::internal', undef)
  $keystone_admin    = pick($admin_endpoint, "http://${keystone_admin_ip}")
  $keystone_internal = pick($internal_endpoint, "http://${keystone_admin_ip}")

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::nova::base
  contain ::ntnuopenstack::nova::firewall::server
  include ::ntnuopenstack::nova::munin::api
  include ::ntnuopenstack::nova::neutron

  if($confhaproxy) {
    contain ::ntnuopenstack::nova::haproxy::backend::api
    contain ::ntnuopenstack::nova::haproxy::backend::metadata
  }

  if($nova_admin_ip) {
    contain ::ntnuopenstack::nova::keepalived
  }

  class { '::nova::keystone::authtoken':
    auth_url          => "${keystone_admin}:35357/",
    auth_uri          => "${keystone_internal}:5000/",
    password          => $nova_password,
    memcached_servers => $memcache,
    region_name       => $region,
  }

  class { '::nova::api':
    neutron_metadata_proxy_shared_secret => $nova_secret,
    enable_proxy_headers_parsing         => $confhaproxy,
    sync_db                              => $sync_db,
    sync_db_api                          => $sync_db,
  }

  nova_config {
    'cache/enabled':          value => true;
    'cache/backend':          value => 'oslo_cache.memcache_pool';
    'cache/memcache_servers': value => $memcache;
  }
}
