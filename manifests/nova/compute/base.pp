# Basic nova configuration for compute nodes.
class ntnuopenstack::nova::compute::base {
  include ::ntnuopenstack::nova::common::base
  include ::ntnuopenstack::nova::compute::provider
  include ::ntnuopenstack::nova::firewall::compute
  require ::ntnuopenstack::repo

  # The compute-nodes have falsibly been configured with database-parameters.
  # They are not needed there, and should thus be removed.
  nova_config {
    'database/connection':     ensure => absent;
    'api_database/connection': ensure => absent;
  }
}
