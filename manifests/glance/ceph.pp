# Configures ceph for glance use
class ntnuopenstack::glance::ceph {
  $ceph_pool = lookup('ntnuopenstack::glance::ceph::pool', String)
  $ceph_user = lookup('ntnuopenstack::glance::ceph::user', String)
  $users = lookup('profile::ceph::keys', Hash)

  require ::profile::ceph::client

  ceph_config {
    "client.${ceph_user}/key": value => $users["client.${ceph_user}"]['secret'];
  }

  ::profile::ceph::key { "client.${ceph_user}": 
    group => 'glance',
    mode  => '0640',
  }

  ::glance::backend::multistore::rbd { 'ceph-default' :
    manage_packages   => false,
    rbd_store_pool    => $ceph_pool,
    rbd_store_user    => $ceph_user,
    store_description => 'Default CEPH store',
  }
}
