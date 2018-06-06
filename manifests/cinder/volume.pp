# Configures ceph to facilitate for cinder, and for cinder to use ceph for
# storage.
class ntnuopenstack::cinder::volume {
  $ceph_uuid = hiera('ntnuopenstack::nova::ceph::uuid')

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::cinder::base
  contain ::ntnuopenstack::cinder::ceph

  class { '::cinder::volume': }
  class { '::cinder::volume::rbd':
    rbd_pool        => 'volumes',
    rbd_user        => 'nova',
    rbd_secret_uuid => $ceph_uuid,
  }
}
