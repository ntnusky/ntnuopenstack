# Installs and configure neutron services
class ntnuopenstack::neutron::services {
  $fw_driver = hiera('profile::neutron::fwaas_driver')

  require ::ntnuopenstack::neutron::base
  require ::ntnuopenstack::repo

  class { '::neutron::services::fwaas':
    enabled => true,
    driver  => $fw_driver,
  }

  neutron_fwaas_service_config {
    'fwaas/agent_version': value => 'v1';
  }

  neutron_l3_agent_config {
    'AGENT/extensions': value => 'fwaas';
  }

  class { 'neutron::services::lbaas':
  }
}
