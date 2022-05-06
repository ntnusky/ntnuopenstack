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
    neutron_config { 'DEFAULT/bgp_drscheduler_driver' :
      value => 'neutron_dynamic_routing.services.bgp.scheduler.bgp_dragent_scheduler.StaticScheduler',
    }
  } else {
    class { '::neutron::agents::bgp_dragent':
      package_ensure => 'absent',
      enabled        => false,
    }
    neutron_config { 'DEFAULT/bgp_drscheduler_driver' :
      ensure => 'abesent',
    }
  }
}
