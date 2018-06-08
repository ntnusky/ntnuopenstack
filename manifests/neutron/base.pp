# Installs the base neutron services.
class ntnuopenstack::neutron::base {
  $service_plugins = hiera('ntnuopenstack::neutron::service_plugins')
  $mtu = hiera('ntnuopenstack::neutron::mtu', undef)
  $transport_url = hiera('ntnuopenstack::transport::url')

  require ::ntnuopenstack::repo
  include ::ntnuopenstack::neutron::sudo

  class { '::neutron':
    allow_overlapping_ips   => true,
    core_plugin             => 'ml2',
    default_transport_url   => $transport_url,
    dhcp_agents_per_network => 2,
    global_physnet_mtu      => $mtu,
    service_plugins         => $service_plugins,
  }
}
