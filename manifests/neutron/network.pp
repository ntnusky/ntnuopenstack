# Installs and configures a neutron network node
class ntnuopenstack::neutron::network {

  $enable_ipv6 = hiera('ntnuopenstack::neutron::tenant::dhcpv6pd', false)
  require ::ntnuopenstack::repo

  contain ::ntnuopenstack::neutron::agents
  contain ::ntnuopenstack::neutron::external
  contain ::ntnuopenstack::neutron::firewall::l3agent
  contain ::ntnuopenstack::neutron::lbaas
  contain ::ntnuopenstack::neutron::services
  contain ::ntnuopenstack::neutron::tenant

  if ($enable_ipv6) {
    contain ::ntnuopenstack::neutron::ipv6::agent
  }
}
