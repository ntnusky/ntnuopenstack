# Configures neutron to connect to the external networks defined in the hiera
# files.
class ntnuopenstack::neutron::external {
  $externalnets = lookup('ntnuopenstack::neutron::networks::external', {
    'value_type' => Hash[String, Hash],
  })
  $connections = lookup('ntnuopenstack::neutron::external::connections', {
    'value_type'    => Hash[String, Hash],
    'default_value' => {},
  })

  require ::vswitch::ovs

  # For each connection to an external network this l3-node should create:
  $connections.each | $netname, $data | {
    # A 'vswitch' connection would indicate that an external network is
    # present at a certain VLAN on a certain vswitch bridge.
    if($data['type'] == 'vswitch') {
      $n = "Connection between ${data['bridge']} and br-${netname}"
      ::profile::infrastructure::ovs::bridge { "br-${netname}" : }
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
  }
}
