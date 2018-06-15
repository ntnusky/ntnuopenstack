# This class installs and configures libvirt for nova's use.
class ntnuopenstack::nova::libvirt {
  $nova_libvirt_type = hiera('ntnuopenstack::nova::libvirt_type')
  $nova_libvirt_model = hiera('ntnuopenstack::nova::libvirt_model')

  $management_if = hiera('profile::interfaces::management')
  $management_ip = getvar("::ipaddress_${management_if}")

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::nova::base::compute

  class { '::nova::compute::libvirt':
    libvirt_cpu_mode        => 'custom',
    libvirt_cpu_model       => $nova_libvirt_model,
    libvirt_disk_cachemodes => [ 'network=writeback' ],
    libvirt_virt_type       => $nova_libvirt_type,
    migration_support       => true,
    vncserver_listen        => $management_ip,
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

