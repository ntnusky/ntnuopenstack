# This class installs munin plugins which monitors the ceph cluster. Should be
# installed on the ceph monitors.
class ntnuopenstack::swift::munin::plugins {
  $pool_prefix = 'default.rgw'
  $pools = ['control', 'meta', 'log', 'buckets.index', 'buckets.data']

  $pools.each | $pool | {
    ::profile::ceph::monitoring::pool { "${pool_prefix}.${pool}": }
  }
}
