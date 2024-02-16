# This class installs and configures nova for a compute-node.
class ntnuopenstack::nova::compute (
  Boolean $localdisk,
) {
  ## TODO: 
  # Use nova::compute::provider for GPU-traits in placement
  include ::ntnuopenstack::nova::auth
  contain ::ntnuopenstack::nova::common::neutron
  require ::ntnuopenstack::nova::compute::base
  include ::ntnuopenstack::nova::compute::logging
  include ::ntnuopenstack::nova::compute::service
  include ::ntnuopenstack::nova::compute::sudo
  include ::ntnuopenstack::nova::munin::compute
  require ::ntnuopenstack::repo

  # In focal we need at least version '2.13.3-7ubuntu5.2' of apparmor to run
  # Yoga. This package is as of 09.march 2023 only available in the
  # proposed-repositores, and is thus manually forced in place like this:
  require ::ntnuopenstack::nova::compute::apparmor

  # Configure libvirt. Need to tell libvirt if local disk(s) should be used or
  # not.
  class { '::ntnuopenstack::nova::compute::libvirt':
    localdisk => $localdisk,
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
