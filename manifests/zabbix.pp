# Configures zabbix to monitor openstack-resources using read-access to the
# databases.
class ntnuopenstack::zabbix {
  $zabbixservers = lookup('profile::zabbix::servers', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::Nosubnet],
  })

  if($zabbixservers =~ Array[Stdlib::IP::Address::Nosubnet, 1]) {
    include ::ntnuopenstack::zabbix::scripts

    file { '/etc/zabbix/zabbix_agent2.d/userparam-openstack.conf':
      ensure  => present,
      owner   => 'zabbix_agent',
      group   => 'zabbix_agent',
      mode    => '0644',
      content => join([
        "UserParameter=openstack.metrics[*],/usr/local/sbin/get-openstack-metrics.py \$1 \$2 \$3",
        "UserParameter=openstack.discover.externalnets[*],/usr/local/sbin/discover-openstack-externalnets.py \$1 \$2 \$3",
        "UserParameter=openstack.discover.hypervisors[*],/usr/local/sbin/discover-openstack-hypervisors.py \$1 \$2 \$3",
        "UserParameter=openstack.discover.magnumtemplates[*],/usr/local/sbin/discover-openstack-magnumtemplates.py \$1 \$2 \$3",
        "UserParameter=openstack.discover.networkagents[*],/usr/local/sbin/discover-openstack-networkagents.py \$1 \$2 \$3",
        "UserParameter=openstack.discover.os[*],/usr/local/sbin/discover-openstack-os.py \$1 \$2 \$3",
        "UserParameter=openstack.discover.subnetpools[*],/usr/local/sbin/discover-openstack-subnetpools.py \$1 \$2 \$3",
      ], "\n"),
      require => Package['zabbix-agent2'],
      notify  => Service['zabbix-agent2'],
    }
  }
}
