# Installs all scripts needed by zabbix to monitor our openstack platforms.
class ntnuopenstack::zabbix::scripts {
  include ::ntnuopenstack::common::pydb

  file { '/usr/lib/python3/dist-packages/zabbixoslib.py':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/ntnuopenstack/zabbix/zabbixoslib.py',
  }

  file { '/usr/local/sbin/get-openstack-metrics.py':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/ntnuopenstack/zabbix/get-openstack-metrics.py',
  }
}
