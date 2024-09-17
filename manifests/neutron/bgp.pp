# Installs and configures the neutron BGP agent
class ntnuopenstack::neutron::bgp {
  $bgp_interface = lookup('ntnuopenstack::neutron::bgp::router::interface', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })

  if($bgp_interface) {
    $bgp_router_id = $::sl2['server']['interfaces'][$bgp_interface]['ipv4']
  } else {
    $bgp_router_id = lookup('ntnuopenstack::neutron::bgp::router::id', {
      'default_value' => '0.0.0.0',
      'value_type'    => Stdlib::IP::Address,
    })
  }

  require ::ntnuopenstack::neutron::base
  include ::ntnuopenstack::neutron::logging::dragent
  require ::ntnuopenstack::repo
  include ::ntnuopenstack::zabbix::neutron::bgp

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
