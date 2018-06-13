# Installs and configure neutron services
class ntnuopenstack::neutron::services {
  $fw_driver = hiera('ntnuopenstack::neutron::fwaas_driver')

  require ::ntnuopenstack::neutron::base
  require ::ntnuopenstack::repo

  class { '::neutron::services::fwaas':
    enabled       => true,
    driver        => $fw_driver,
    agent_version => 'v1',
  }

  neutron_l3_agent_config {
    'AGENT/extensions': value => 'fwaas';
  }

  class { 'neutron::services::lbaas':
  }
}
