# Configures logging for nova-api 
class ntnuopenstack::nova::api::logging {
  # The API-service is logged through apache 
  include ::profile::services::apache::logging

  # Include openstack logfiles
  ntnuopenstack::common::logging { [
    'nova-api',
    'nova-manage',
    'nova-metadata-api',
  ]:
    project     => 'nova',
  }
}
