# Configures logging for neutronnet 
class ntnuopenstack::neutron::logging::net {
  ntnuopenstack::common::logging { [
    'neutron-dhcp-agent',
    'neutron-l3-agent',
    'neutron-metadata-agent',
    'neutron-openvswitch-agent',
    'neutron-ovs-cleanup',
  ] :
    project => 'neutron',
  }
}
