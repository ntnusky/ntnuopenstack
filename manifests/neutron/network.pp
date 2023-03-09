# Installs and configures a neutron network node
class ntnuopenstack::neutron::network {
  require ::ntnuopenstack::repo

  contain ::ntnuopenstack::neutron::agents
  contain ::ntnuopenstack::neutron::base
  contain ::ntnuopenstack::neutron::external
  include ::ntnuopenstack::neutron::logging::net
  include ::ntnuopenstack::neutron::nolbaas
  contain ::ntnuopenstack::neutron::tenant
  contain ::profile::monitoring::munin::plugin::openstack::neutronnet
}
