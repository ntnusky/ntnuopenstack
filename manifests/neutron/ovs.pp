# This class configures the neutron ml2 ovs agent.
class ntnuopenstack::neutron::ovs (
  $tenant_mapping,
  $manage_vswitch = true,
  $local_ip       = undef,
  $tunnel_types   = undef,
) {
  $connections = lookup('ntnuopenstack::neutron::external::connections', {
    'value_type'    => Hash[String, Variant[String, Hash]],
    'default_value' => {},
  })

  require ::ntnuopenstack::neutron::base
  require ::ntnuopenstack::repo

  $external_mappings = $connections.map | $key, $value | {
    "${key}:br-${key}"
  }

  $bridge_mappings = [ $tenant_mapping ]
  $mappings = concat($bridge_mappings, $external_mappings)

  class { '::neutron::agents::ml2::ovs':
    bridge_mappings => $mappings,
    manage_vswitch  => $manage_vswitch,
    local_ip        => $local_ip,
    tunnel_types    => $tunnel_types,
  }

  neutron_agent_ovs { 'ovs/ovsdb_timeout':
    value => 60,
  }
}
