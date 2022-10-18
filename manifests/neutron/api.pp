# Installs and configures the neutron api
class ntnuopenstack::neutron::api {
  # Create a list of memceche-servers.
  $cache_servers = lookup('profile::memcache::servers', {
    'value_type' => Array[Stdlib::IP::Address],
    'merge'      => 'unique',
  })
  $memcache = $cache_servers.map | $server | {
    "${server}:11211"
  }

  # Determine where the keystone service is located.
  $keystone_admin = lookup('ntnuopenstack::keystone::endpoint::admin', Stdlib::Httpurl)
  $keystone_public = lookup('ntnuopenstack::keystone::endpoint::public', Stdlib::Httpurl)

  # Openstack parameters
  $region = lookup('ntnuopenstack::region', String)
  $sync_db = lookup('ntnuopenstack::neutron::db::sync', Boolean)
  $nova_password = lookup('ntnuopenstack::nova::keystone::password', String)
  $neutron_password = lookup('ntnuopenstack::neutron::keystone::password', String)
  $service_providers = lookup('ntnuopenstack::neutron::service_providers', {
    'value_type'    => Array[String],
    'default_value' => [],
  })
  $register_loadbalancer = lookup('profile::haproxy::register', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  require ::ntnuopenstack::neutron::base
  require ::ntnuopenstack::neutron::dbconnection
  include ::ntnuopenstack::neutron::firewall::api
  include ::ntnuopenstack::neutron::haproxy::backend
  include ::ntnuopenstack::neutron::logging::api
  include ::ntnuopenstack::neutron::ml2::config
  include ::profile::monitoring::munin::plugin::openstack::neutronapi

  # Configure how neutron communicates with keystone
  class { '::neutron::keystone::authtoken':
    password             => $neutron_password,
    auth_url             => "${keystone_admin}:5000/",
    www_authenticate_uri => "${keystone_public}:5000/",
    memcached_servers    => $memcache,
    region_name          => $region,
  }

  # Install the neutron api
  class { '::neutron::server':
    allow_automatic_l3agent_failover => true,
    allow_automatic_dhcp_failover    => true,
    enable_proxy_headers_parsing     => $register_loadbalancer,
    service_providers                => $service_providers,
    sync_db                          => $sync_db,
  }

  # Configure nova notifications system
  class { '::neutron::server::notifications':
    auth_url    => "${keystone_admin}:5000",
    password    => $nova_password,
    region_name => $region,
  }
}
