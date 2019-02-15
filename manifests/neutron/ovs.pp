# This class configures the neutron ml2 ovs agent.
class ntnuopenstack::neutron::ovs (
  $tenant_mapping,
  $local_ip         = undef,
  $tunnel_types     = undef,
) {
  $external_networks = lookup('profile::neutron::external::networks', {
    'default_value' => [],
    'value_type'    => Array[String],
    'merge'         => 'unique',
  })

  require ::ntnuopenstack::neutron::base
  require ::ntnuopenstack::repo

  $external = $external_networks.map |$net| {
    $bridge = lookup("profile::neutron::external::${net}::bridge", String)
    "${net}:${bridge}"
  }

  $bridge_mappings = [ $tenant_mapping ]
  $mappings = concat($bridge_mappings, $external)

  class { '::neutron::agents::ml2::ovs':
    bridge_mappings => $mappings,
    local_ip        => $local_ip,
    tunnel_types    => $tunnel_types,
  }
}
