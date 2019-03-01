# This class configures the neutron ml2 ovs agent.
class ntnuopenstack::neutron::ovs (
  $tenant_mapping,
  $local_ip         = undef,
  $tunnel_types     = undef,
) {
  $connections = lookup('ntnuopenstack::neutron::external::connections', {
    'value_type'    => Hash[String, String],
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
    local_ip        => $local_ip,
    tunnel_types    => $tunnel_types,
  }
}
