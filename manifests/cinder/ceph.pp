# Configures ceph to facilitate for cinder, and for cinder to use ceph for
# storage.
class ntnuopenstack::cinder::ceph {
  $ceph_key = lookup('ntnuopenstack::cinder::ceph::key', String)

  $backends = lookup('ntnuopenstack::cinder::rbd::backends', {
    'value_type'    => Hash[String, String],
    'default_value' => {
      'rbd-images' => 'volumes',
    },
  })

  $pools = $backends.values().unique
  $poolaccess = $pools.map | $pool | {
    "allow rwx pool=${pool}"
  }
  $poolaccessstr = $poolaccess.join(', ')
  $images = 'allow rwx pool=images'

  require ::profile::ceph::client

  ceph_config {
    'client.cinder/key': value => $ceph_key;
  }

  ceph::key { 'client.cinder':
    secret  => $ceph_key,
    cap_mon => 'allow r, allow command "osd blacklist"',
    cap_osd => "allow class-read object_prefix rbd_children, ${poolaccessstr}, ${images}",
    inject  => true,
    group   => 'cinder',
    mode    => '0640',
  }
}
