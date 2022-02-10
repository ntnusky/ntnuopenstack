# This class formats and mounts a disk so that nova-compute can use it to store
# cached glance-images and VM ephemeral disks.
class ntnuopenstack::nova::compute::disk {
  $blockdevice = lookup('ntnuopenstack::compute::disk::device', {
    'value_type' => String,
  })

  $type = lookup('ntnuopenstack::compute::disk::type', {
    'default_value' => 'filesystem',
    'value_type'    => Enum['filesystem', 'lvm'],
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

  if($type == 'filesystem') {
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

    nova_config {
      'libvirt/images_type': ensure => absent;
    }
  } else {
    nova_config {
      'libvirt/images_type':         value => 'lvm';
      'libvirt/images_volume_group': value => 'novacompute';
    }
  }

  file { '/var/lib/nova/instances':
    ensure  => 'directory',
    group   => 'nova',
    owner   => 'nova',
    require => Mount['/var/lib/nova/instances'],
  }

}
