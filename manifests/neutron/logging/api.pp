# Configures logging for neutron 
class ntnuopenstack::neutron::logging::api {
  ntnuopenstack::common::logging {'neutron-server':
    project => 'neutron',
  }
}
