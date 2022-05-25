# Configures logging for nova-services 
class ntnuopenstack::nova::services::logging {

  # Include openstack logfiles
  ntnuopenstack::common::logging { [
    'nova-conductor',
    'nova-novncproxy',
    'nova-scheduler',
  ]:
    project     => 'nova',
  }
}
