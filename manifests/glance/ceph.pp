# Configures ceph for glance use
class ntnuopenstack::glance::ceph {
  $glance_key = lookup('ntnuopenstack::glance::ceph::key', String)

  require ::profile::ceph::client

  exec { '/usr/bin/ceph osd pool create images 32' :
    unless  => '/usr/bin/ceph osd pool get images size',
  }

  ceph_config {
      'client.glance/key': value => $glance_key;
  }

  ceph::key { 'client.glance':
    secret  => $glance_key,
    cap_mon => 'allow r, allow command "osd blacklist"',
    cap_osd =>
      'allow class-read object_prefix rbd_children, allow rwx pool=images',
    inject  => true,
  }

  class { '::glance::backend::rbd' :
    rbd_store_user => 'glance',
  }
}
