# Installs various nova services.
class ntnuopenstack::nova::services {
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

  include ::nova::conductor
  include ::ntnuopenstack::nova::common::neutron
  require ::ntnuopenstack::nova::services::base
  include ::ntnuopenstack::nova::services::vncproxy
  require ::ntnuopenstack::repo

  class { '::nova::scheduler':
    discover_hosts_in_cells_interval => $discover_interval,
  }

  class { '::nova::scheduler::filter':
    scheduler_default_filters       => $default_filters_real,
    build_failure_weight_multiplier => 0,
  }
}
