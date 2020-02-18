# Installs and configure neutron services
class ntnuopenstack::neutron::services {
  $fw_driver = lookup('ntnuopenstack::neutron::fwaas_driver', {
    'value_type'    => String,
    'default_value' =>
      'neutron_fwaas.services.firewall.service_drivers.agents.drivers.linux.iptables_fwaas_v2.IptablesFwaasDriver',
  })

  require ::ntnuopenstack::neutron::base
  require ::ntnuopenstack::repo

  class { '::neutron::services::fwaas':
    enabled       => true,
    driver        => $fw_driver,
    agent_version => 'v2',
  }

  class { '::neutron::services::lbaas':
  }
}
