# Configures nova to use LVM to store its ephemeral disks.
class ntnuopenstack::nova::compute::disk::lvm {
  $clear_method = lookup('ntnuopenstack::compute::disk::clear::method', {
    'default_value' => 'zero',
    'value_type'    => Enum['zero', 'shred', 'none'],
  })
  $clear_size = lookup('ntnuopenstack::compute::disk::clear::size', {
    'default_value' => 0,
    'value_type'    => Integer,
  })

  require ntnuopenstack::nova::compute::disk

  nova_config {
    'libvirt/images_volume_group': value => 'novacompute';
    'libvirt/volume_clear':        value => $clear_method;
    'libvirt/volume_clear_size':   value => $clear_size;
  }
}
