# This class installs munin plugins which monitors the ceph cluster. Should be
# installed on the ceph monitors.
class ntnuopenstack::swift::munin::plugins {
  include ::profile::ceph::monitoring::collectors
  include ::profile::monitoring::munin::plugin::ceph::base
  include ::profile::systemd::reload

  $pool_prefix = "default.rgw"
  $pools = ['control', 'meta', 'log', 'buckets.index', 'buckets.data']

  $pools.each | $pool | {
    # Configure systemd service
    file { "/lib/systemd/system/cephcollector.${pool_prefix}.${pool}.service":
      ensure => file,
      mode   => '0644',
      owner  => root,
      group  => root,
      notify => Exec['ceph-systemd-reload'],
      content => epp('ntnuopenstack/cephcollector.service.epp', {
        'pool_name' => "${pool_prefix}.${pool}"
      })
    }

    # Make sure the service is running
    service { "cephcollector.${pool_prefix}.${pool}":
      ensure   => running,
      enable   => true,
      provider => 'systemd',
      require  => [
        File["/lib/systemd/system/cephcollector.${pool_prefix}.${pool}.service"],
        File['/usr/local/sbin/ceph-collector.sh'],
        Exec['ceph-systemd-reload'],
      ],
    }

    munin::plugin { "ceph_traffic_${pool_prefix}.${pool}":
      ensure  => link,
      target  => 'ceph_traffic_',
      require => File['/usr/share/munin/plugins/ceph_traffic_'],
      config  => ['user root'],
    }

    munin::plugin { "ceph_iops_${pool_prefix}.${pool}":
      ensure  => link,
      target  => 'ceph_iops_',
      require => File['/usr/share/munin/plugins/ceph_iops_'],
      config  => ['user root'],
    }
  }
}
