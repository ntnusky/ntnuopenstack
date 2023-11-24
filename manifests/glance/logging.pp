# Configures logging for glance 
class ntnuopenstack::glance::logging {
  # The API-service is logged through apache 
  include ::profile::services::apache::logging

  ntnuopenstack::common::logging { 'glance-api':
    project => 'glance',
  }
}
