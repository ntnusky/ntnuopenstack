# Installs and configures the neutron api
class ntnuopenstack::neutron::api {
  # Determine the correct database settings
  $mysql_password = hiera('ntnuopenstack::neutron::mysql::password')
  $mysql_old = hiera('profile::mysql::ip', undef)
  $mysql_new = hiera('profile::haproxy::management::ipv4', undef)
  $mysql_ip = pick($mysql_new, $mysql_old)
  $database_connection = "mysql://neutron:${mysql_password}@${mysql_ip}/neutron"

  # Retrieve the addresses for the memcached servers.
  $memcached_ip = hiera('profile::memcache::ip', undef)
  $memcache_servers = hiera_array('profile::memcache::servers', undef)
  $memcache_servers_real = pick($memcache_servers, [$memcached_ip])
  $memcache = $memcache_servers_real.map | $server | {
    "${server}:11211"
  }

  # Retrieve service IP Addresses
  $keystone_admin_ip  = hiera('profile::api::keystone::admin::ip', '127.0.0.1')
  $keystone_public_ip = hiera('profile::api::keystone::public::ip', '127.0.0.1')

  # Retrieve api urls, if they exist. 
  $admin_endpoint    = hiera('ntnuopenstack::endpoint::admin', undef)
  $internal_endpoint = hiera('ntnuopenstack::endpoint::internal', undef)
  $public_endpoint   = hiera('ntnuopenstack::endpoint::public', undef)

  # Determine which endpoint to use
  $keystone_admin    = pick($admin_endpoint, "http://${keystone_admin_ip}")
  $keystone_internal = pick($internal_endpoint, "http://${keystone_admin_ip}")

  # Openstack settings
  $nova_password = hiera('ntnuopenstack::nova::keystone::password')
  $neutron_password = hiera('ntnuopenstack::neutron::keystone::password')
  $service_providers = hiera('ntnuopenstack::neutron::service_providers')
  $region = hiera('ntnuopenstack::region')

  # Should haproxy be configured?
  $confhaproxy = hiera('ntnuopenstack::haproxy::configure::backend', true)

  require ::ntnuopenstack::neutron::base
  include ::ntnuopenstack::neutron::firewall::api
  include ::ntnuopenstack::neutron::ml2::config
  contain ::ntnuopenstack::neutron::ipv6::config
  include ::profile::services::memcache::pythonclient

  if($keystone_admin_ip != '127.0.0.1') {
    contain ::ntnuopenstack::neutron::keepalived
  }

  if($confhaproxy) {
    contain ::ntnuopenstack::neutron::haproxy::backend::server
  }

  # Configure how neutron communicates with keystone
  class { '::neutron::keystone::authtoken':
    password          => $neutron_password,
    auth_url          => "${keystone_admin}:35357/",
    auth_uri          => "${keystone_internal}:5000/",
    memcached_servers => $memcache,
    region_name       => $region,
  }

  # Install the neutron api
  class { '::neutron::server':
    database_connection              => $database_connection,
    sync_db                          => true,
    allow_automatic_l3agent_failover => true,
    allow_automatic_dhcp_failover    => true,
    service_providers                => $service_providers,
    enable_proxy_headers_parsing     => $confhaproxy,
  }

  # Configure nova notifications system
  class { '::neutron::server::notifications':
    password    => $nova_password,
    auth_url    => "${keystone_admin}:35357",
    region_name => $region,
  }

  class { 'neutron::services::lbaas':
  }
}
