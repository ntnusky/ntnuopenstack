# This class configures the ceph user used by nova.
#
# [*ephemeral_storage*]
#  (optional) Wheter or not to use the ceph driver for novas ephemeral storage.
#    Setting this option to false means to use ceph for cinder only.
class ntnuopenstack::nova::compute::ceph (
  $ephemeral_storage,
) {
  $nova_uuid = lookup('ntnuopenstack::nova::ceph::uuid')
  $ceph_user = lookup('ntnuopenstack::nova::ceph::user', {
    'default_value' => 'nova',
    'value_type'    => String, 
  })
  $ceph_pool = lookup('ntnuopenstack::nova::ceph::ephemeral::pool', {
    'default_value' => 'volumes',
    'value_type'    => String,
  })
  $users = lookup('profile::ceph::keys', Hash)

  include ::ntnuopenstack::nova::compute::ceph::client

  # Configure nova to use ceph.
  class { '::nova::compute::rbd':
    libvirt_rbd_user        => $ceph_user,
    libvirt_images_rbd_pool => $ceph_pool,
    libvirt_rbd_secret_uuid => $nova_uuid,
    libvirt_rbd_secret_key  => $users["client.${ceph_user}"]['secret'],
    manage_ceph_client      => false,
    ephemeral_storage       => $ephemeral_storage,
  }
}
