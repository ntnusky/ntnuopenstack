# Configures neutron for the ML2 plugin.
class ntnuopenstack::neutron::ml2::config {
  $k = 'ntnuopenstack::neutron::tenant::isolation::type' 
  $tenant_network_strategy = lookup($k)

  if($tenant_network_strategy == 'vlan') {
    $vlan_low = lookup('ntnuopenstack::neutron::vlan_low', Integer)
    $vlan_high = lookup('ntnuopenstack::neutron::vlan_high', Integer)

    class { '::neutron::plugins::ml2':
      type_drivers         => ['vlan', 'flat'],
      tenant_network_types => ['vlan'],
      mechanism_drivers    => ['openvswitch', 'l2population'],
      network_vlan_ranges  => ["physnet-vlan:${vlan_low}:${vlan_high}"],
    }
  } elsif($tenant_network_strategy == 'vxlan') {
    $vni_low = lookup('ntnuopenstack::neutron::vni_low', Integer)
    $vni_high = lookup('ntnuopenstack::neutron::vni_high', Integer)

    class { '::neutron::plugins::ml2':
      type_drivers         => ['vxlan', 'flat'],
      tenant_network_types => ['vxlan'],
      mechanism_drivers    => ['openvswitch', 'l2population'],
      vni_ranges           => "${vni_low}:${vni_high}"
    }
  } else {
    fail("The hiera key ${k} can only be 'vlan' or 'vxlan'")
  }
}
