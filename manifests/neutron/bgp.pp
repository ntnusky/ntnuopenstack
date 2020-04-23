# Installs and configures the neutron BGP agent
class ntnuopenstack::neutron::bgp {
  $bgp_router_id = lookup('ntnuopenstack::neutron::bgp::router::id', {
    'value_type'    => Stdlib::IP::Address,
    'default_value' => '0.0.0.0',
  })

  require ::ntnuopenstack::neutron::base
  require ::ntnuopenstack::repo

  if($bgp_router_id != '0.0.0.0') {
    class { '::neutron::agents::bgp_dragent':
      bgp_router_id => $bgp_router_id,
    }
  }
}
