# Configures logging for cinder 
class ntnuopenstack::cinder::logging {
  # The API-service is logged through apache 
  include ::profile::services::apache::logging

  # Some services runs standalone 
  ntnuopenstack::common::logging { [
    'cinder-scheduler',
    'cinder-volume',
  ]:
    project => 'cinder',
  }
}
