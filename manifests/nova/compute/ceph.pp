# This class configures the ceph user used by nova.
#
# [*ephemeral_storage*]
#  (optional) Wheter or not to use the ceph driver for novas ephemeral storage.
#    Setting this option to false means to use ceph for cinder only.
class ntnuopenstack::nova::compute::ceph (
  $ephemeral_storage,
) {
  $nova_uuid = lookup('ntnuopenstack::nova::ceph::uuid')

  include ::ntnuopenstack::nova::compute::ceph::client

  # Configure nova to use ceph.
  class { '::nova::compute::rbd':
    libvirt_rbd_user        => 'nova',
    libvirt_images_rbd_pool => 'volumes',
    libvirt_rbd_secret_uuid => $nova_uuid,
    manage_ceph_client      => false,
    ephemeral_storage       => $ephemeral_storage,
  }
}
