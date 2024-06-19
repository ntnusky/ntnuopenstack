# Configures logging for neutron
class ntnuopenstack::neutron::logging::api {

  # The API-services is loggedn through apache
  include ::profile::services::apache::logging

  ntnuopenstack::common::logging { [
    'neutron-server',
    'neutron-rpc-server',
  ]:
    project => 'neutron',
  }
}
