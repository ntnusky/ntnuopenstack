# Configures ceph to facilitate for cinder, and for cinder to use ceph for
# storage.
class ntnuopenstack::cinder::ceph {
  $ceph_user = lookup('ntnuopenstack::cinder::ceph::user', String)
  $users = lookup('profile::ceph::keys', Hash)

  require ::profile::ceph::client

  ceph_config {
    "${ceph_user}/key": value => $users[$ceph_user]['secret'];
  }

  ::profile::ceph::key { $ceph_user: }
}
