# This class prepares a LVM VG for novas use.
class ntnuopenstack::nova::compute::disk {
  $blockdevices = lookup('ntnuopenstack::compute::disks', {
    'value_type' => Array[String],
  })

  $blockdevices.each | $dev | {
    physical_volume { $dev:
      ensure    => present,
      unless_vg => 'novacompute',
    }
  }

  volume_group { 'novacompute':
    ensure           => present,
    createonly       => true,
    physical_volumes => $blockdevices,
  }
}
