# Configures neutron for the ML2 plugin.
class ntnuopenstack::neutron::ml2::config {
  $low = lookup('ntnuopenstack::neutron::tenant::isolation::id::low', Integer)
  $high = lookup('ntnuopenstack::neutron::tenant::isolation::id::high', Integer)
  $strategy = lookup('ntnuopenstack::neutron::tenant::isolation::type', {
    'value_type' => Enum['vlan', 'vxlan'],
  })

  if($strategy == 'vlan') {
    class { '::neutron::plugins::ml2':
      type_drivers         => ['vlan', 'flat'],
      tenant_network_types => ['vlan'],
      mechanism_drivers    => ['openvswitch', 'l2population'],
      network_vlan_ranges  => ["physnet-vlan:${low}:${high}"],
    }
  } elsif($strategy == 'vxlan') {
    class { '::neutron::plugins::ml2':
      type_drivers         => ['vxlan', 'flat'],
      tenant_network_types => ['vxlan'],
      mechanism_drivers    => ['openvswitch', 'l2population'],
      vni_ranges           => "${low}:${high}"
    }
  }
}
