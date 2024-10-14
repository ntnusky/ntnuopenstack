# Configures ceph to facilitate for cinder, and for cinder to use ceph for
# storage.
class ntnuopenstack::cinder::ceph {
  $ceph_user = lookup('ntnuopenstack::cinder::ceph::user', String)
  $users = lookup('profile::ceph::keys', Hash)

  require ::profile::ceph::client

  ceph_config {
    "client.${ceph_user}/key": value => $users["client.${ceph_user}"]['secret'];
  }

  ::profile::ceph::key { "client.${ceph_user}": }
}
