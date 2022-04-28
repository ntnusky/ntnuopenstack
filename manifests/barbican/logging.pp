# Configures logging for barbican 
class ntnuopenstack::barbican::logging {
  # The API-service is logged through apache 
  include ::profile::services::apache::logging

  # Some services runs standalone 
  ntnuopenstack::common::logging { [
    'barbican-api',
    'barbican-worker',
  ]:
    project => 'barbican',
  }
}
