# Configures ceph to facilitate for cinder, and for cinder to use ceph for
# storage.
class ntnuopenstack::cinder::ceph {
  $ceph_key = hiera('ntnuopenstack::cinder::ceph::key')

  require ::profile::ceph::client

  ceph_config {
    'client.nova/key': value => $ceph_key;
  }

  ceph::key { 'client.cinder':
    secret  => $ceph_key,
    cap_mon => "allow r, allow command \"osd blacklist\"",
    cap_osd =>
      'allow class-read object_prefix rbd_children, allow rwx pool=volumes',
    inject  => true,
  }
}
