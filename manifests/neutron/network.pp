# Installs and configures a neutron network node
class ntnuopenstack::neutron::network {
  require ::ntnuopenstack::repo

  contain ::ntnuopenstack::neutron::agents
  contain ::ntnuopenstack::neutron::external
  contain ::ntnuopenstack::neutron::firewall::l3agent
  contain ::ntnuopenstack::neutron::lbaas
  contain ::ntnuopenstack::neutron::services
  contain ::ntnuopenstack::neutron::tenant
  contain ::profile::monitoring::munin::plugin::openstack::neutronnet

  # This class is to remove the rest of the DHCPv6-pd config. This can be
  # removed when upgrading to Train.
  contain ::ntnuopenstack::neutron::ipv6::pddisable
}
