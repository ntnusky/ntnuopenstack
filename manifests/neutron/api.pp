# Installs and configures the neutron api
class ntnuopenstack::neutron::api {
  # Determine where the database is
  $mysql_password = lookup('ntnuopenstack::neutron::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::neutron::mysql::ip', Stdlib::IP::Address)
  $database_connection = "mysql://neutron:${mysql_password}@${mysql_ip}/neutron"

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
  $keystone_internal = lookup('ntnuopenstack::keystone::endpoint::internal', Stdlib::Httpurl)

  # Openstack parameters
  $region = lookup('ntnuopenstack::region', String)
  $nova_password = lookup('ntnuopenstack::nova::keystone::password', String)
  $neutron_password = lookup('ntnuopenstack::neutron::keystone::password', String)
  $service_providers = lookup('ntnuopenstack::neutron::service_providers', {
    'value_type'    => Array[String],
    'default_value' => [
      'FIREWALL:Iptables:neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver:default',
      'LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default',
    ],
  })
  $enable_ipv6_pd = lookup('ntnuopenstack::neutron::tenant::dhcpv6pd', {
    'value_type'    => Boolean,
    'default_value' => false,
  })
  $confhaproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  require ::ntnuopenstack::neutron::base
  include ::ntnuopenstack::neutron::firewall::api
  include ::ntnuopenstack::neutron::ml2::config
  include ::profile::services::memcache::pythonclient

  if ($enable_ipv6_pd) {
    contain ::ntnuopenstack::neutron::ipv6::config
  }

  if($confhaproxy) {
    contain ::ntnuopenstack::neutron::haproxy::backend
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
