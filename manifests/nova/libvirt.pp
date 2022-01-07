# This class installs and configures libvirt for nova's use.
class ntnuopenstack::nova::libvirt {
  # We can instruct libvirt to expose a certain CPU-model to our VM's. This is
  # useful to allow live-migration between hosts. If a model is specified A
  # 'least-common-denominator' CPU model, supported by all compute-nodes where
  # live-migration is relevant, should be configured in hiera. In addition
  # compute-nodes can have additional models configured in a list in their
  # node-specific hiera allowing some flavors to have a richer IA.
  # If the value is not set, the VM will get the same IA as the host.
  $cpu_model = lookup('ntnuopenstack::nova::cpu::base_model', {
    'default_value' => undef,
    'value_type'    => Variant[Undef, String],
  })
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

  if($cpu_model) {
    $cpuconfig = {
      cpu_mode   => 'custom',
      cpu_models => [ $cpu_model ] + $cpu_models,
    }
  } else {
    $cpuconfig = {
      cpu_mode => 'host-passthrough',
    }
  }

  class { '::nova::compute::libvirt':
    cpu_model_extra_flags => $cpu_model_extra_flags,
    disk_cachemodes       => [ 'network=writeback' ],
    migration_support     => true,
    vncserver_listen      => $management_ip,
    *                     => $cpuconfig,
  }
}
