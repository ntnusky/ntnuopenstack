# Configures logging for neutron DR-Agent 
class ntnuopenstack::neutron::logging::dragent {
  ntnuopenstack::common::logging {'neutron-bgp-dragent':
    project => 'neutron',
  }
}
