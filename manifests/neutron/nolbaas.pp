# Uninstalls old neutron lbaas packages
class ntnuopenstack::neutron::nolbaas {
  package { [
      'neutron-lbaas-common',
      'neutron-lbaasv2-agent',
      'python3-neutron-lbaas', ] :
    ensure => 'absent',
  }
}
