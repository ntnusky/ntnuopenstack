# Installs all scripts needed by zabbix to monitor our openstack platforms.
class ntnuopenstack::zabbix::scripts {
  include ::ntnuopenstack::common::pydb

  $scripts = [
    'discover-openstack-externalnets.py',
    'discover-openstack-hypervisors.py',
    'discover-openstack-magnumtemplates.py',
    'discover-openstack-networkagents.py',
    'discover-openstack-os.py',
    'discover-openstack-subnetpools.py',
    'get-openstack-metrics.py',
  ]

  file { '/usr/lib/python3/dist-packages/zabbixoslib.py':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/ntnuopenstack/zabbix/zabbixoslib.py',
  }

  $scripts.each | $script | {
    file { "/usr/local/sbin/${script}":
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => "puppet:///modules/ntnuopenstack/zabbix/${script}",
    }
  }
}
