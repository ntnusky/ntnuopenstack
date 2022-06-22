# Configures a filesystem for nova, so that it can store ephemeral disks there.
class ntnuopenstack::nova::compute::disk::filesystem {
  require ntnuopenstack::nova::compute::disk

  logical_volume { 'ephemeral':
    ensure       => present,
    volume_group => 'novacompute',
    size         => undef,          #undef means "all available space"
    before       => Filesystem['/dev/novacompute/ephemeral'],
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

  file { '/var/lib/nova/instances':
    ensure  => 'directory',
    group   => 'nova',
    owner   => 'nova',
    require => Mount['/var/lib/nova/instances'],
  }
}
