# This class installs and configures nova for a compute-node.
class ntnuopenstack::nova::compute (
  Boolean $localdisk,
) {
  contain ::ntnuopenstack::nova::common::neutron
  require ::ntnuopenstack::nova::compute::base
  contain ::ntnuopenstack::nova::compute::libvirt
  include ::ntnuopenstack::nova::compute::logging
  include ::ntnuopenstack::nova::compute::service
  include ::ntnuopenstack::nova::compute::sudo
  include ::ntnuopenstack::nova::munin::compute
  require ::ntnuopenstack::repo

  if($localdisk) {
    require ::ntnuopenstack::nova::compute::disk
  }

  class { '::ntnuopenstack::nova::compute::ceph':
    ephemeral_storage => ! $localdisk,
  }

  # Determine if sensu should be installed, and in that case include a sensu
  # subscription.
  $install_sensu = lookup('profile::sensu::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })
  if ($install_sensu) {
    sensu::subscription { 'os-compute': }
  }
}
