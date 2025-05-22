# This class installs and configures nova for a compute-node.
class ntnuopenstack::nova::compute (
  Boolean $localdisk,
) {
  ## TODO: 
  # Use nova::compute::provider for GPU-traits in placement
  include ::ntnuopenstack::nova::auth
  contain ::ntnuopenstack::nova::common::cinder
  contain ::ntnuopenstack::nova::common::neutron
  require ::ntnuopenstack::nova::compute::base
  include ::ntnuopenstack::nova::compute::logging
  include ::ntnuopenstack::nova::compute::service
  include ::ntnuopenstack::nova::compute::sudo
  require ::ntnuopenstack::repo

  # Configure libvirt. Need to tell libvirt if local disk(s) should be used or
  # not.
  class { '::ntnuopenstack::nova::compute::libvirt':
    localdisk => $localdisk,
  }
}
