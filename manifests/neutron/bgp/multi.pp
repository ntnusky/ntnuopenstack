# Installs and configures multiple bgp routing agents 
class ntnuopenstack::neutron::bgp::multi {
  require ::ntnuopenstack::neutron::base
  include ::ntnuopenstack::neutron::logging::dragent
  require ::ntnuopenstack::repo
  include ::ntnuopenstack::zabbix::neutron::bgp

  include ::neutron::deps
  include ::neutron::params

  $agents = lookup('ntnuopenstack::neutron::bgp::agents', {
    'default_value' => {},
    'value_type'    => Hash[String, Hash],
  })

  $agents.each | $agentname, $data | {
    ::ntnuopenstack::neutron::bgp::agent { $agentname:
      interface => $data['interface'],
    }
  }

  package { 'neutron-bgp-dragent':
    ensure => present,
    name   => $::neutron::params::bgp_dragent_package,
    tag    => ['openstack', 'neutron-package'],
  }
}
