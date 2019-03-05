# Configures neutron to connect to the external networks defined in the hiera
# files.
class ntnuopenstack::neutron::external {
  $externalnets = lookup('ntnuopenstack::neutron::networks::external', {
    'value_type' => Hash[String, Hash],
  })
  $connections = lookup('ntnuopenstack::neutron::external::connections', {
    'value_type'    => Hash[String, String],
    'default_value' => {},
  })

  require ::vswitch::ovs

  # For each connection to an external network this l3-node should create:
  $connections.each | $netname, $interface | {
    # If a VLAN-ID is set there is a need for a virtual patch between the ovs
    # bridge connected to the physical interface and the ovs bridge representing
    # the virtual network.
    if('vlanid' in $externalnets[$netname]) {
      $n = "${interface}-${externalnets[$netname]['vlanid']}-br-${netname}"
      ::profile::infrastructure::ovs::patch { $n :
        physical_if => $interface,
        vlan_id     => $externalnets[$netname]['vlanid'],
        ovs_bridge  => "br-${netname}",
      }

    # If there is not a VLAN ID set the bridge representing the virtual network
    # can simply be connected to the physical interface
    } else {
      vs_port { $interface:
        ensure => present,
        bridge => "br-${netname}",
      }
    }
  }
}
