# Installs and configures a neutron network node
class ntnuopenstack::neutron::network {
  require ::ntnuopenstack::repo

  contain ::ntnuopenstack::neutron::agents
  contain ::ntnuopenstack::neutron::external
  contain ::ntnuopenstack::neutron::firewall::l3agent
  include ::ntnuopenstack::neutron::logging::net
  include ::ntnuopenstack::neutron::nolbaas
  contain ::ntnuopenstack::neutron::services
  contain ::ntnuopenstack::neutron::tenant
  contain ::profile::monitoring::munin::plugin::openstack::neutronnet
}
