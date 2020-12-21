# Installs various nova services.
class ntnuopenstack::nova::services {
  require ::ntnuopenstack::nova::base
  include ::ntnuopenstack::nova::neutron
  include ::ntnuopenstack::nova::vncproxy
  require ::ntnuopenstack::repo

  $default_filters = [
    'AggregateImagePropertiesIsolation',
    'AvailabilityZoneFilter',
    'ComputeFilter',
    'ComputeCapabilitiesFilter',
    'ImagePropertiesFilter',
    'ServerGroupAntiAffinityFilter',
    'ServerGroupAffinityFilter'
  ]

  $default_filters_real = lookup('ntnuopenstack::nova::default_scheduling_filters', {
    'default_value' => $default_filters,
    'value_type'    => Array[String],
  })

  $discover_interval = lookup('ntnuopenstack::nova::discover_hosts_interval', {
    'default_value' => 3600,
    'value_type'    => Integer,
  })

  class { '::nova::conductor':
    enabled => true,
  }

  class { '::nova::scheduler':
    discover_hosts_in_cells_interval => $discover_interval,
  }

  class { '::nova::scheduler::filter':
    scheduler_default_filters => $default_filters_real,
  }

  nova_config {
    'filter_scheduler/build_failure_weight_multiplier':
      value => 0;
  }
}
