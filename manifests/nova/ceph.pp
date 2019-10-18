# This class configures ceph for nova.
class ntnuopenstack::nova::ceph {
  require ::profile::ceph::client

  $nova_key = lookup('ntnuopenstack::cinder::ceph::key')

  exec { '/usr/bin/ceph osd pool create volumes 32' :
    unless => '/usr/bin/ceph osd pool get volumes size',
  }

  ceph_config {
    'client.nova/key': value => $nova_key;
  }

  ensure_packages( ['python3-rbd', 'python3-rados'] , {
    'ensure' => 'present',
  })

  $top = 'allow class-read object_prefix rbd_children'
  $volumes = 'allow rwx pool=volumes'
  $images = 'allow rwx pool=images'
  ceph::key { 'client.nova':
    secret  => $nova_key,
    cap_mon => 'allow r, allow command \"osd blacklist\"',
    cap_osd => "${top},${volumes}, ${images}",
    inject  => true,
  }
}
