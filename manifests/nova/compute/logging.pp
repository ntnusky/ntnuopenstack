# Configures logging for nova-compute 
class ntnuopenstack::nova::compute::logging {
  # Include libvirt logs
  include ::profile::services::libvirt::logging

  # Include openstack logfiles
  profile::utilities::logging::file { 'nova-compute':
    paths => [
      '/var/log/nova/nova-compute.log',
      '/var/log/nova/privsep-helper.log',
    ],
    multiline => {
      'type'    => 'pattern',
      'pattern' => '^[0-9]{4}-[0-9]{2}-[0-9]{2}',
      'negate'  => 'true',
      'match'   => 'after',
    },
    tags  => [ 'openstack', 'nova', 'nova-compute' ],
  }
}
