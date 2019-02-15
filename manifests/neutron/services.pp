# Installs and configure neutron services
class ntnuopenstack::neutron::services {
  $fw_driver = lookup('ntnuopenstack::neutron::fwaas_driver', String)

  require ::ntnuopenstack::neutron::base
  require ::ntnuopenstack::repo

  class { '::neutron::services::fwaas':
    enabled       => true,
    driver        => $fw_driver,
    agent_version => 'v1',
  }

  class { '::neutron::services::lbaas':
  }
}
