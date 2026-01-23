# Installs various nova services.
class ntnuopenstack::nova::services {
  $enabled_filters = [
    'AggregateImagePropertiesIsolation',
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

  $pci_in_placement = lookup('ntnuopenstack::nova::scheduler::enable_pci_in_placement', {
    'default_value' => false,
    'value_type'    => Boolean,
  })

  require ::ntnuopenstack::nova::auth
  include ::ntnuopenstack::nova::common::cinder
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
    enabled_filters                 => $enabled_filters_real,
    build_failure_weight_multiplier => 0,
    pci_in_placement                => $pci_in_placement,
  }
}
