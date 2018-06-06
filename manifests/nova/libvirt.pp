# This class installs and configures libvirt for nova's use.
class ntnuopenstack::nova::libvirt {
  $nova_libvirt_type = hiera('ntnuopenstack::nova::libvirt_type')
  $nova_libvirt_model = hiera('ntnuopenstack::nova::libvirt_model')

  $management_if = hiera('profile::interfaces::management')
  $management_ip = getvar("::ipaddress_${management_if}")

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::nova::base::compute

  class { '::nova::compute::libvirt':
    vncserver_listen        => $management_ip,
    libvirt_virt_type       => $nova_libvirt_type,
    libvirt_cpu_mode        => 'custom',
    libvirt_cpu_model       => $nova_libvirt_model,
    libvirt_disk_cachemodes => [ 'network=writeback' ],
  }

  $common = 'VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE'
  class { '::nova::migration::libvirt':
    live_migration_flag  => $common,
    block_migration_flag => "${common}, VIR_MIGRATE_NON_SHARED_INC",
  }

  file { '/etc/libvirt/qemu.conf':
    ensure => present,
    source => 'puppet:///modules/ntnuopenstack/qemu.conf',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service['libvirt'],
  }

  Package['libvirt'] -> File['/etc/libvirt/qemu.conf']
}

