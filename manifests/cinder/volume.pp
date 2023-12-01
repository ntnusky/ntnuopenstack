# Configures ceph to facilitate for cinder, and for cinder to use ceph for
# storage.
class ntnuopenstack::cinder::volume {
  $ceph_uuid = lookup('ntnuopenstack::nova::ceph::uuid', String)

  $backends = lookup('ntnuopenstack::cinder::rbd::backends', {
    'value_type'    => Hash[String, String],
    'default_value' => {
      'rbd-images' => 'volumes',
    },
  })

  $types = lookup('ntnuopenstack::cinder::types', {
    'value_type'    => Hash[String, Hash[String, Variant[String, Hash]]],
    'default_value' => {
      'Normal'      => {
        'backend' => 'rbd-images',
      },
    },
  })

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::clients
  require ::ntnuopenstack::cinder::base
  contain ::ntnuopenstack::cinder::ceph

  class { '::cinder::volume': }

  class { 'cinder::backends':
    backend_host = undef,
    enabled_backends => $backends.keys(),
  }

  $backends.each | $bname, $pool | {
    cinder::backend::rbd { $bname :
      rbd_pool        => $pool,
      rbd_user        => 'cinder',
      rbd_secret_uuid => $ceph_uuid,
    }
  }

  $types.each | $typename, $data | {
    $backend = $data['backend']

    $props = pick($data['properties'], {}).map | $key, $value | {
      "${key}=${value}"
    }

    cinder_type { $typename :
      ensure     => pick($data['ensure'], present),
      is_public  => pick($data['public'], true),
      properties => concat([ "volume_backend_name=${backend}" ], $props),
    }
  }
}
