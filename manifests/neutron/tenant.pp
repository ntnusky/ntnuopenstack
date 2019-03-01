# Configures neutron for the appropriate tenant network strategy
class ntnuopenstack::neutron::tenant {
  $k = 'ntnuopenstack::neutron::tenant::isolation::type'
  $tenant_network_strategy = lookup($k, String)

  if($tenant_network_strategy == 'vlan') {
    include ::ntnuopenstack::neutron::tenant::vlan
  } elsif($tenant_network_strategy == 'vxlan') {
    include ::ntnuopenstack::neutron::tenant::vxlan
  } else {
    fail("The hiera key ${k} can only be 'vlan' or 'vxlan'")
  }
}
