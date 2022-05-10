# This class prepares a LVM VG for novas use.
class ntnuopenstack::nova::compute::disk {
  $blockdevice = lookup('ntnuopenstack::compute::disk::device', {
    'value_type' => String,
  })

  physical_volume { $blockdevice:
    ensure    => present,
    unless_vg => 'novacompute',
  }

  volume_group { 'novacompute':
    ensure           => present,
    createonly       => true,
    physical_volumes => $blockdevice,
  }
}
