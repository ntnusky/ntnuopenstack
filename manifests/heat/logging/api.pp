# Configures logging for heat 
class ntnuopenstack::heat::logging::api {
  # The API-service is logged through apache
  include ::profile::services::apache::logging

  ntnuopenstack::common::logging { [
    'heat-api',
    'heat-api-cfn',
  ]:
    project => 'heat',
  }
}
