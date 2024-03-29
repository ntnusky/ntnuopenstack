# Configures ceph for glance use
class ntnuopenstack::glance::ceph {
  $glance_key = lookup('ntnuopenstack::glance::ceph::key', String)

  require ::profile::ceph::client

  ceph_config {
      'client.glance/key': value => $glance_key;
  }

  ceph::key { 'client.glance':
    secret  => $glance_key,
    cap_mon => 'allow r, allow command "osd blocklist"',
    cap_osd =>
      'allow class-read object_prefix rbd_children, allow rwx pool=images',
    inject  => true,
  }

  ::glance::backend::multistore::rbd { 'ceph-default' :
    manage_packages   => false,
    rbd_store_pool    => 'images',
    rbd_store_user    => 'glance',
    store_description => 'Default CEPH store',
  }
}
