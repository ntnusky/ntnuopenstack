# Configures logging for keystone 
class ntnuopenstack::keystone::logging {
  # The API-service is logged through apache 
  include ::profile::services::apache::logging

  # Some services runs standalone 
  ntnuopenstack::common::logging { [
    'keystone',
    'keystone-manage',
  ]:
    project => 'keystone',
  }
}
