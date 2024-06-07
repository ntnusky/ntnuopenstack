# Installs various nova services.
class ntnuopenstack::nova::services {
  $enabled_filters = [
    'AggregateImagePropertiesIsolation',
    'AvailabilityZoneFilter',
    'ComputeFilter',
    'ComputeCapabilitiesFilter',
    'ImagePropertiesFilter',
    'ServerGroupAntiAffinityFilter',
    'ServerGroupAffinityFilter'
  ]

  $enabled_filters_real = lookup('ntnuopenstack::nova::default_scheduling_filters', {
    'default_value' => $enabled_filters,
    'value_type'    => Array[String],
  })

  $discover_interval = lookup('ntnuopenstack::nova::discover_hosts_interval', {
    'default_value' => 3600,
    'value_type'    => Integer,
  })

  require ::ntnuopenstack::nova::auth
  include ::ntnuopenstack::nova::common::neutron
  require ::ntnuopenstack::nova::dbconnection
  include ::ntnuopenstack::nova::quota
  require ::ntnuopenstack::nova::services::base
  include ::ntnuopenstack::nova::services::logging
  include ::ntnuopenstack::nova::services::vncproxy
  require ::ntnuopenstack::repo

  class { '::nova::conductor' : }

  class { '::nova::scheduler':
    discover_hosts_in_cells_interval => $discover_interval,
  }

  class { '::nova::scheduler::filter':
    scheduler_enabled_filters       => $enabled_filters_real,
    build_failure_weight_multiplier => 0,
  }
}
