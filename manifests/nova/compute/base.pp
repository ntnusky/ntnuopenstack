# Basic nova configuration for compute nodes.
class ntnuopenstack::nova::compute::base {
  include ::ntnuopenstack::nova::compute::id
  include ::ntnuopenstack::nova::compute::provider
  include ::ntnuopenstack::nova::firewall::compute
  require ::ntnuopenstack::repo

  $cpu_allocation = lookup('ntnuopenstack::nova::compute::ratio::cpu', {
    'default_value' => '16.0',
    'value_type'    => String,
  })

  $ram_allocation = lookup('ntnuopenstack::nova::compute::ratio::ram', {
    'default_value' => '1.1',
    'value_type'    => String,
  })

  $disk_allocation = lookup('ntnuopenstack::nova::compute::ratio::disk', {
    'default_value' => '1.0',
    'value_type'    => String,
  })

  class { '::ntnuopenstack::nova::common::base':
    extra_options => {
      initial_cpu_allocation_ratio  => $cpu_allocation,
      initial_ram_allocation_ratio  => $ram_allocation,
      initial_disk_allocation_ratio => $disk_allocation,
    }
  }
}
