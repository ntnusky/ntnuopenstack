# Configures neutron for the ML2 plugin.
class ntnuopenstack::neutron::ml2::config {
  $low = lookup('ntnuopenstack::neutron::tenant::isolation::id::low', Integer)
  $high = lookup('ntnuopenstack::neutron::tenant::isolation::id::high', Integer)
  $strategy = lookup('ntnuopenstack::neutron::tenant::isolation::type', {
    'value_type' => Enum['vlan', 'vxlan', 'combo'],
  })
  $tenant_nettypes = lookup('ntnuopenstack::neutron::tenant::network::types', {
    'default_value' => [ $strategy ],
    'value_type'    => Array[Enum['vlan', 'vxlan']],
  })

  $connections = lookup('ntnuopenstack::neutron::external::connections', {
    'value_type'    => Hash[String, Variant[String, Hash]],
    'default_value' => {},
  })

  $physnetmtu = $connections.map | $key, $value | {
    $mtu = pick($value['mtu'], 1500)
    "${key}:${mtu}"
  }

  $extension_drivers = lookup('ntnuopenstack::neutron::ml2::extension_drivers', {
    'value_type'    => Array[String],
    'default_value' => ['port_security'],
  })

  if($strategy in ['vlan', 'combo']) {
    $vlan_high = lookup('ntnuopenstack::neutron::tenant::vlan::id::high', {
      'default_value' => $high,
      'value_type'    => Integer[1,4094],
    })
    $vlan_low = lookup('ntnuopenstack::neutron::tenant::vlan::id::low', {
      'default_value' => $low,
      'value_type'    => Integer[1,4094],
    })

    $vlan_ranges = ["physnet-vlan:${vlan_low}:${vlan_high}"]
    $vlan_type_driver = ['vlan']
  } else {
    $vlan_ranges = []
    $vlan_type_driver = []
  }

  if($strategy in ['vxlan', 'combo']) {
    $vxlan_high = lookup('ntnuopenstack::neutron::tenant::vxlan::id::high', {
      'default_value' => $high,
      'value_type'    => Integer[0,16777215],
    })
    $vxlan_low = lookup('ntnuopenstack::neutron::tenant::vxlan::id::low', {
      'default_value' => $low,
      'value_type'    => Integer[0,16777215],
    })

    $vni_ranges = "${low}:${high}"
    $vxlan_type_driver = ['vxlan']
  } else {
    $vni_ranges = '10:100' # The default in puppet-neutron
    $vxlan_type_driver = []
  }

  class { '::neutron::plugins::ml2':
    extension_drivers     => $extension_drivers,
    mechanism_drivers     => ['openvswitch', 'l2population'],
    network_vlan_ranges   => $vlan_ranges,
    physical_network_mtus => $physnetmtu,
    project_network_types => $tenant_nettypes,
    type_drivers          => [ 'flat' ] + $vlan_type_driver + $vxlan_type_driver,
    vni_ranges            => $vni_ranges,
  }
}
