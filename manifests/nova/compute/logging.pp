# Configures logging for nova-compute 
class ntnuopenstack::nova::compute::logging {
  # Include libvirt logs
  include ::profile::services::libvirt::logging

  # Include openstack logfiles
  ntnuopenstack::common::logging {'nova-compute':
    project     => 'nova',
    extra_paths => [ '/var/log/nova/privsep-helper.log' ],
  }
}
