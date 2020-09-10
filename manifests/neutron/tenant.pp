# Configures neutron for the appropriate tenant network strategy
class ntnuopenstack::neutron::tenant {
  $strategy = lookup('ntnuopenstack::neutron::tenant::isolation::type', {
    'value_type' => Enum['vlan', 'vxlan']
  })

  if($strategy == 'vlan') {
    include ::ntnuopenstack::neutron::tenant::vlan
  } elsif($strategy == 'vxlan') {
    include ::ntnuopenstack::neutron::tenant::vxlan
  }
}
