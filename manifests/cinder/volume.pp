# Configures ceph to facilitate for cinder, and for cinder to use ceph for
# storage.
class ntnuopenstack::cinder::volume {
  $ceph_uuid = hiera('ntnuopenstack::nova::ceph::uuid')

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::clients
  require ::ntnuopenstack::cinder::base
  contain ::ntnuopenstack::cinder::ceph

  class { '::cinder::volume': }

  cinder::backend::rbd {'rbd-images':
    rbd_pool        => 'volumes',
    rbd_user        => 'nova',
    rbd_secret_uuid => $ceph_uuid,
  }

  cinder_type {'Slow':
    ensure     => present,
    properties => ['volume_backend_name=rbd-images'],
  }

  cinder_type {'Normal':
    ensure     => present,
    properties => ['volume_backend_name=rbd-images'],
  }

  cinder_type {'Fast':
    ensure     => present,
    properties => ['volume_backend_name=rbd-images'],
  }

  cinder_type {'Unlimited':
    ensure     => present,
    properties => ['volume_backend_name=rbd-images'],
  }

  class { 'cinder::backends':
    enabled_backends => ['rbd-images']
  }
}
