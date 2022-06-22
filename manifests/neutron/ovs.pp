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

  $ovsdb_timeout = lookup('ntnuopenstack::neutron::ovs::db::timeout', {
    'value_type'    => Integer,
    'default_value' => 60,
  })

  $firewall_driver = lookup('ntnuopenstack::neutron::ovs::firewall_driver', {
    'default_value' => 'openvswitch',
    'value_type'    => String,
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
    firewall_driver => $firewall_driver,
    local_ip        => $local_ip,
    manage_vswitch  => $manage_vswitch,
    ovsdb_timeout   => $ovsdb_timeout,
    tunnel_types    => $tunnel_types,
  }
}
