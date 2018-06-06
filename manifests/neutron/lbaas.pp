# Installs the lbaas agents on a neutron network node
class ntnuopenstack::neutron::lbaas {
  class { 'neutron::services::lbaas::haproxy' : }
  class { 'neutron::agents::lbaas' : }
}
