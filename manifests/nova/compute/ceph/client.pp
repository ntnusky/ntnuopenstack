# This class installs the ceph client and configures the nova-key. 
class ntnuopenstack::nova::compute::ceph::client {
  $nova_key = lookup('ntnuopenstack::cinder::ceph::key')

  $backends = lookup('ntnuopenstack::cinder::rbd::backends', {
    'value_type'    => Hash[String, String],
    'default_value' => {
      'rbd-images' => 'volumes',
    },
  })

  # For each unique backend (avoid configuring the same backend multiple times
  # even if it is used for multiple cinder volume types), add relevant ceph
  # parameters giving access to the relevant pools.
  $pools = $backends.values().unique
  $poolaccess = $pools.map | $pool | {
    "allow rwx pool=${pool}"
  }

  require ::profile::ceph::client

  # Configure ceph to accept the ceph-key for nova
  ceph_config {
    'client.nova/key': value => $nova_key;
  }

  # Configure the ceph nova-user to have read/write/execute access to all the
  # relevant pools.
  $top = 'allow class-read object_prefix rbd_children'
  $volumes = $poolaccess.join(', ')
  $images = 'allow rwx pool=images'
  ceph::key { 'client.nova':
    secret  => $nova_key,
    cap_mon => 'allow r, allow command "osd blocklist"',
    cap_osd => "${top}, ${volumes}, ${images}",
    inject  => true,
  }
}
