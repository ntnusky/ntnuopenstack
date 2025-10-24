# Installs and configures multiple bgp routing agents 
class ntnuopenstack::neutron::bgp::multi {
  include ::ntnuopenstack::neutron::base
  include ::ntnuopenstack::neutron::logging::dragent
  include ::ntnuopenstack::repo
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

  Systemd::Manage_unit['neutron-bgp-multiagent@.service']
  -> Service <| tag == 'neutron-bgp-mutiagent-service' |>

  systemd::manage_unit { 'neutron-bgp-multiagent@.service':
    enable        => false,
    active        => false,
    path          => '/lib/systemd/system',
    unit_entry    => {
      'After'       => [
        'network-online.target',
        'local-fs.target',
        'remote-fs.target',
      ],
      'Wants'       => [
        'network-online.target',
        'local-fs.target',
        'remote-fs.target',
        'neutron-bgp.target',
      ],
      'PartOf'      => [
        'neutron-bgp.target',
      ],
      'Before'      => [
        'neutron-bgp.target',
      ],
      'Description' => 'Neutron BGP DR-Agent'
    },
    service_entry => {
      'Type'             => 'simple',
      'User'             => 'neutron',
      'Group'            => 'neutron',
      'ExecStart'        => join([
        '/usr/bin/python3 /usr/bin/neutron-bgp-dragent',
        '--config-file=/etc/neutron/neutron.conf',
        '--config-file=/etc/neutron/bgp_dragent_%i.ini',
        '--log-file=/var/log/neutron/neutron-bgp-dragent-%i.log',
      ], ' '),
      'TimeoutSec'       => '15',
      'CPUAccounting'    => true,
      'MemoryAccounting' => true,
      'TasksAccounting'  => true,
      'ExecStartPre'     => '[ -e /etc/neutron/bgp_dragent_%i.ini ]',
    },
    install_entry => {
      'WantedBy'  => [
        'neutron-bgp.target',
      ]
    },
  }

  systemd::manage_unit { 'neutron-bgp.target':
    enable        => true,
    active        => true,
    path          => '/lib/systemd/system',
    unit_entry    => {
      'Description' => 'Service to start/stop all local neutron BGP agents'
    },
    install_entry => {
      'WantedBy'  => 'multi-user.target',
    },
  }

  package { 'neutron-bgp-dragent':
    ensure => present,
    name   => $::neutron::params::bgp_dragent_package,
    tag    => ['openstack', 'neutron-package'],
  }
}
