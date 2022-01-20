# Configures neutron for the ML2 plugin.
class ntnuopenstack::neutron::ml2::config {
  $low = lookup('ntnuopenstack::neutron::tenant::isolation::id::low', Integer)
  $high = lookup('ntnuopenstack::neutron::tenant::isolation::id::high', Integer)
  $strategy = lookup('ntnuopenstack::neutron::tenant::isolation::type', {
    'value_type' => Enum['vlan', 'vxlan'],
  })

  $connections = lookup('ntnuopenstack::neutron::external::connections', {
    'value_type'    => Hash[String, Variant[String, Hash]],
    'default_value' => {},
  })

  $physnetmtu = $connections.map | $key, $value | {
    $mtu = pick($value['mtu'], 1500)
    "${key}:${mtu}"
  }

  if($strategy == 'vlan') {
    class { '::neutron::plugins::ml2':
      extension_drivers     => ['port_security'],
      mechanism_drivers     => ['openvswitch', 'l2population'],
      network_vlan_ranges   => ["physnet-vlan:${low}:${high}"],
      physical_network_mtus => $physnetmtu,
      tenant_network_types  => ['vlan'],
      type_drivers          => ['vlan', 'flat'],
    }
  } elsif($strategy == 'vxlan') {
    class { '::neutron::plugins::ml2':
      extension_drivers     => ['port_security'],
      mechanism_drivers     => ['openvswitch', 'l2population'],
      physical_network_mtus => $physnetmtu,
      tenant_network_types  => ['vxlan'],
      type_drivers          => ['vxlan', 'flat'],
      vni_ranges            => "${low}:${high}"
    }
  }
}
