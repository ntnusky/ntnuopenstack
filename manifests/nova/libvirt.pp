# This class installs and configures libvirt for nova's use.
class ntnuopenstack::nova::libvirt {
  $nova_libvirt_type = lookup('ntnuopenstack::nova::libvirt_type', {
    'default_value' => 'kvm',
    'value_type'    => Enum['kvm', 'qemu'],
  })

  # A 'least-common-denominator' CPU model, supported by all our compute-nodes,
  # should be configured in global hiera. In addition compute-nodes can have
  # additional models configured in a list in their node-specific hiera.
  $cpu_model = lookup('ntnuopenstack::nova::cpu::base_model', String)
  $cpu_models = lookup('ntnuopenstack::nova::cpu::extra_models', {
    'default_value' => [],
    'value_type'    => Array[String],
  })

  # A boolean to determine if we should allow nested virtualization
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
    cpu_mode              => 'custom',
    cpu_models            => [ $cpu_model ] + $cpu_models,
    cpu_model_extra_flags => $cpu_model_extra_flags,
    disk_cachemodes       => [ 'network=writeback' ],
    migration_support     => true,
    virt_type             => $nova_libvirt_type,
    vncserver_listen      => $management_ip,
  }
}

