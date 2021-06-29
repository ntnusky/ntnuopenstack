# This class installs and configures libvirt for nova's use.
class ntnuopenstack::nova::libvirt {
  $nova_libvirt_type = lookup('ntnuopenstack::nova::libvirt_type')
  $nova_libvirt_model = lookup('ntnuopenstack::nova::libvirt_model')
  $nova_nested_virt = lookup('ntnuopenstack::nova::nested_virtualization', {
    'default_value' => false,
    'value_type'    => Boolean
  })

  $management_if = lookup('profile::interfaces::management')
  $management_ip = getvar("::ipaddress_${management_if}")

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::nova::base::compute

  $cpu_model_extra_flags = $nova_nested_virt ? {
    true  => 'vmx',
    false => undef
  }

  class { '::nova::compute::libvirt':
    libvirt_cpu_mode              => 'custom',
    libvirt_cpu_model             => $nova_libvirt_model,
    libvirt_cpu_model_extra_flags => $cpu_model_extra_flags,
    libvirt_disk_cachemodes       => [ 'network=writeback' ],
    libvirt_virt_type             => $nova_libvirt_type,
    migration_support             => true,
    vncserver_listen              => $management_ip,
  }

  #  file { '/etc/libvirt/qemu.conf':
  #    ensure => present,
  #    source => 'puppet:///modules/ntnuopenstack/qemu.conf',
  #    owner  => 'root',
  #    group  => 'root',
  #    mode   => '0644',
  #    notify => Service['libvirt'],
  #  }
  #
  #  Package['libvirt'] -> File['/etc/libvirt/qemu.conf']
}

