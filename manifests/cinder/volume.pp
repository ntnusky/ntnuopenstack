# Configures ceph to facilitate for cinder, and for cinder to use ceph for
# storage.
class ntnuopenstack::cinder::volume {
  $ceph_uuid = lookup('ntnuopenstack::nova::ceph::uuid', String)
  $ceph_user = lookup('ntnuopenstack::nova::ceph::user', {
    'default_value' => 'nova',
    'value_type'    => String,
  })

  $backends = lookup('ntnuopenstack::cinder::rbd::backends', {
    'default_value' => {
      'rbd-images' => 'volumes',
    },
    'value_type'    => Hash[String, String],
  })

  $disk_geometry = lookup('ntnuopenstack::cinder::rbd::disk_geometry', {
    'default_value' => undef,
    'value_type'    => Enum['512', '512e', '4k', undef],
  })

  $types = lookup('ntnuopenstack::cinder::types', {
    'default_value' => {
      'Normal'      => {
        'backend' => 'rbd-images',
      },
    },
    'value_type'    => Hash[String, Hash[String, Variant[String, Hash]]],
  })

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::clients
  require ::ntnuopenstack::cinder::base
  contain ::ntnuopenstack::cinder::ceph

  class { '::cinder::volume': }

  # We can not use cinder::backends and cinder::backend::rbd together
  # It will always default to not configuring the differen backend hosts..
  cinder_config {
    'DEFAULT/enabled_backends': value => join($backends.keys(), ',');
  }


  $backends.each | $bname, $pool | {
    if ( $disk_geometry ) {
      $geometry = {
        'extra_options' => { "${bname}/disk_geometry" => { 'value' => $disk_geometry } }
      }
    } else {
      $geometry = {}
    }
    cinder::backend::rbd { $bname :
      enable_deferred_deletion => true,
      manage_package           => false,
      rbd_pool                 => $pool,
      rbd_user                 => $ceph_user,
      rbd_secret_uuid          => $ceph_uuid,
      *                        => $geometry,
    }
  }

  $types.each | $typename, $data | {
    $backend = { volume_backend_name => $data['backend'] }
    $props = $backend + pick($data['properties'], {})

    cinder_type { $typename :
      ensure     => pick($data['ensure'], present),
      is_public  => pick($data['public'], true),
      properties => $props,
    }
  }
}
