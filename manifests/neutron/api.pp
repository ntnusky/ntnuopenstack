# Installs and configures the neutron api
class ntnuopenstack::neutron::api {
  # Openstack parameters
  $sync_db = lookup('ntnuopenstack::neutron::db::sync', Boolean)
  $service_providers = lookup('ntnuopenstack::neutron::service_providers', {
    'value_type'    => Optional[Array[String]],
    'default_value' => undef,
  })
  $register_loadbalancer = lookup('profile::haproxy::register', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  require ::ntnuopenstack::neutron::auth
  require ::ntnuopenstack::neutron::base
  require ::ntnuopenstack::neutron::dbconnection
  include ::ntnuopenstack::neutron::firewall::api
  include ::ntnuopenstack::neutron::haproxy::backend
  include ::ntnuopenstack::neutron::logging::api
  include ::ntnuopenstack::neutron::ml2::config
  include ::ntnuopenstack::neutron::rpc

  # Install the neutron api
  class { '::neutron::server':
    allow_automatic_l3agent_failover => true,
    allow_automatic_dhcp_failover    => true,
    api_service_name                 => 'httpd',
    enable_proxy_headers_parsing     => $register_loadbalancer,
    rpc_service_name                 => 'neutron-rpc-server',
    service_name                     => false,
    service_providers                => $service_providers,
    sync_db                          => $sync_db,
  }

  if($register_loadbalancer) {
    $logformat = 'forwarded'
  } else {
    $logformat = false
  }

  class { '::neutron::wsgi::apache':
    access_log_format => $logformat,
    ssl               => false,
  }
}
