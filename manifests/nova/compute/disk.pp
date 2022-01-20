# This class formats and mounts a disk so that nova-compute can use it to store
# cached glance-images and VM ephemeral disks.
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

  logical_volume { 'ephemeral':
    ensure       => present,
    volume_group => 'novacompute',
    size         => undef,          #undef means "all available space"
  }

  filesystem { '/dev/novacompute/ephemeral':
    ensure  => present,
    fs_type => 'ext4',
  }

  mount { '/var/lib/nova/instances':
    ensure  => 'mounted',
    device  => '/dev/novacompute/ephemeral',
    fstype  => 'ext4',
    require => Filesystem['/dev/novacompute/ephemeral'],
  }
}
