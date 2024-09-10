# Configures zabbix to monitor BGP-sessions on our neutron BGP agents
class ntnuopenstack::zabbix::neutron::bgp {
  $zabbixservers = lookup('profile::zabbix::agent::servers', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::Nosubnet],
  })

  if($zabbixservers =~ Array[Stdlib::IP::Address::Nosubnet, 1]) {
    file { '/usr/local/sbin/get-bgp-sessions.py':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/ntnuopenstack/zabbix/get-bgp-sessions.py',
    }

    file { '/etc/zabbix/zabbix_agent2.d/userparam-neutronbgp.conf':
      ensure  => present,
      owner   => 'zabbix_agent',
      group   => 'zabbix_agent',
      mode    => '0644',
      content => join([
        "UserParameter=openstack.neutron.bgp,/usr/local/sbin/get-bgp-sessions.py",
      ], "\n"),
      require => Package['zabbix-agent2'],
      notify  => Service['zabbix-agent2'],
    }
  }
}
