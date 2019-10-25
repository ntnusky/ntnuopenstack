# Configures neutron to connect to the external networks defined in the hiera
# files.
class ntnuopenstack::neutron::external {
  $externalnets = lookup('ntnuopenstack::neutron::networks::external', {
    'value_type' => Hash[String, Hash],
  })
  $connections = lookup('ntnuopenstack::neutron::external::connections', {
    'value_type'    => Hash[String, Variant[String, Hash]],
    'default_value' => {},
  })

  require ::vswitch::ovs

  # For each connection to an external network this l3-node should create:
  $connections.each | $netname, $data | {
    # If the data is a hash, its the new-style configuration.
    if($data =~ Hash) {
      # A 'vswitch' connection would indicate that an external network is
      # present at a certain VLAN on a certain vswitch bridge.
      if($data['type'] == 'vswitch') {
        $n = "Connection between ${data['bridge']} and br-${netname}"
        ::profile::infrastructure::ovs::patch::vlan { $n:
          source_bridge      => $data['bridge'],
          source_vlan        => $data['vlan'],
          destination_bridge => "br-${netname}",
        }

      # An 'interface' connection would mean that a physical interface is
      # dedicated to a certain external network.
      } elsif ($data['type'] == 'interface') {
        vs_port { $data['interface']:
          ensure => present,
          bridge => "br-${netname}",
        }

      # It an unknown type is defined; fail with an error.
      } else {
        fail("${data['type']} is an invalid type for an external network")
      }

    # If the data is a string, we use 'old-style' syntax, and in that case data
    # should be an interface name.
    } elsif($data =~ String) {
      # If a VLAN-ID is set there is a need for a virtual patch between the ovs
      # bridge connected to the physical interface and the ovs bridge representing
      # the virtual network.
      if('vlanid' in $externalnets[$netname]) {
        $n = "${data}-${externalnets[$netname]['vlanid']}-br-${netname}"
        ::profile::infrastructure::ovs::patch { $n :
          physical_if => $data,
          vlan_id     => $externalnets[$netname]['vlanid'],
          ovs_bridge  => "br-${netname}",
        }

      # If there is not a VLAN ID set the bridge representing the virtual network
      # can simply be connected to the physical interface
      } else {
        vs_port { $data:
          ensure => present,
          bridge => "br-${netname}",
        }
      }
    }
  }
}
