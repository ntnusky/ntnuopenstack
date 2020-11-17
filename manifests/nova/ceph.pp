# This class configures ceph for nova.
class ntnuopenstack::nova::ceph {
  require ::profile::ceph::client

  $nova_key = lookup('ntnuopenstack::cinder::ceph::key')

  $backends = lookup('ntnuopenstack::cinder::rbd::backends', {
    'value_type'    => Hash[String, String],
    'default_value' => {
      'rbd-images' => 'volumes',
    },
  })

  $volumes = $backends.values().unique
  $poolaccess = $volumes.map | $pool | {
    "allow rwx pool=${pool}"
  }


  exec { '/usr/bin/ceph osd pool create volumes 32' :
    unless => '/usr/bin/ceph osd pool get volumes size',
  }

  ceph_config {
    'client.nova/key': value => $nova_key;
  }

  $top = 'allow class-read object_prefix rbd_children'
  $volumes = $poolaccess.join(', ')
  $images = 'allow rwx pool=images'
  ceph::key { 'client.nova':
    secret  => $nova_key,
    cap_mon => 'allow r, allow command "osd blacklist"',
    cap_osd => "${top}, ${volumes}, ${images}",
    inject  => true,
  }
}
