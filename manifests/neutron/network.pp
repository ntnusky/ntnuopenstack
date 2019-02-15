# Installs and configures a neutron network node
class ntnuopenstack::neutron::network {
  $enable_ipv6_pd = lookup('ntnuopenstack::neutron::tenant::dhcpv6pd', {
    'value_type'    => Boolean,
    'default_value' => false,
  })

  require ::ntnuopenstack::repo

  contain ::ntnuopenstack::neutron::agents
  contain ::ntnuopenstack::neutron::external
  contain ::ntnuopenstack::neutron::firewall::l3agent
  contain ::ntnuopenstack::neutron::lbaas
  contain ::ntnuopenstack::neutron::services
  contain ::ntnuopenstack::neutron::tenant

  if ($enable_ipv6_pd) {
    contain ::ntnuopenstack::neutron::ipv6::agent
  }
}
