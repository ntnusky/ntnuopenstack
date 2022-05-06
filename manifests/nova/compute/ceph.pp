# This class configures the ceph user used by nova.
#
# [*ephemeral_storage*]
#  (optional) Wheter or not to use the ceph driver for novas ephemeral storage.
#    Setting this option to false means to use ceph for cinder only.
class ntnuopenstack::nova::compute::ceph (
  $ephemeral_storage,
) {
  $nova_uuid = lookup('ntnuopenstack::nova::ceph::uuid')
  $nova_key = lookup('ntnuopenstack::cinder::ceph::key')

  $backends = lookup('ntnuopenstack::cinder::rbd::backends', {
    'value_type'    => Hash[String, String],
    'default_value' => {
      'rbd-images' => 'volumes',
    },
  })

  # For each unique backend (avoid configuring the same backend multiple times
  # even if it is used for multiple cinder volume types), add relevant ceph
  # parameters giving access to the relevant pools.
  $pools = $backends.values().unique
  $poolaccess = $pools.map | $pool | {
    "allow rwx pool=${pool}"
  }

  require ::profile::ceph::client

  # Configure ceph to accept the ceph-key for nova
  ceph_config {
    'client.nova/key': value => $nova_key;
  }

  # Configure the ceph nova-user to have read/write/execute access to all the
  # relevant pools.
  $top = 'allow class-read object_prefix rbd_children'
  $volumes = $poolaccess.join(', ')
  $images = 'allow rwx pool=images'
  ceph::key { 'client.nova':
    secret  => $nova_key,
    cap_mon => 'allow r, allow command "osd blacklist"',
    cap_osd => "${top}, ${volumes}, ${images}",
    inject  => true,
  }

  # Configure nova to use ceph.
  class { '::nova::compute::rbd':
    libvirt_rbd_user        => 'nova',
    libvirt_images_rbd_pool => 'volumes',
    libvirt_rbd_secret_uuid => $nova_uuid,
    manage_ceph_client      => false,
    ephemeral_storage       => $ephemeral_storage,
  }

  class { '::nova::glance':
    enable_rbd_download => true,
    rbd_user            => 'nova',
    rbd_pool            => 'images',
  }
}
