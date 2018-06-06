# Configures iptables for neutron
class ntnuopenstack::neutron::firewall::l3agent {
  require ::profile::baseconfig::firewall

  firewall { '511 neutron-openvswi-INPUT':
    jump  => 'neutron-openvswi-INPUT',
    proto => 'all',
  }
}
