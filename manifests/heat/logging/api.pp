# Configures logging for heat 
class ntnuopenstack::heat::logging::api {
  ntnuopenstack::common::logging { [
    'heat-api',
    'heat-api-cfn',
  ]:
    project => 'cinder',
  }
}
