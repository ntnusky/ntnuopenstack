# Basic nova configuration for compute nodes.
class ntnuopenstack::nova::compute::base {
  include ::ntnuopenstack::nova::common::placement
  include ::ntnuopenstack::nova::common::sudo
  include ::ntnuopenstack::nova::firewall::compute
  require ::ntnuopenstack::repo

  class { '::ntnuopenstack::nova::common::base':
    extra_options => {
      'block_device_allocate_retries' => 120,
    },
  }

  nova_config {
    'api_database/connection': ensure => absent;
  }
}
