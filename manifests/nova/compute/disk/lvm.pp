# Configures nova to use LVM to store its ephemeral disks.
class ntnuopenstack::nova::compute::disk::lvm {
  require ntnuopenstack::nova::compute::disk

  nova_config {
    'libvirt/images_volume_group': value => 'novacompute';
  }
}
