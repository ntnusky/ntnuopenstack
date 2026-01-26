# This class installs and configures libvirt for nova's use.
class ntnuopenstack::nova::compute::libvirt (
  Boolean $localdisk,
){
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

  # Allow to define a libvirt machine-type. For instance to allow VM's to have
  # more than 1TB of memory.
  # An example of a valid value: 'x86_64=pc-i440fx-focal-hpb'
  $machine_type = lookup('ntnuopenstack::nova::libvirt::machine_type', {
    'default_value' => undef,
    'value_type'    => Variant[Undef, String],
  })

  # A boolean to determine if we should allow nested virtualization
  $nova_nested_virt = lookup('ntnuopenstack::nova::nested_virtualization', {
    'default_value' => false,
    'value_type'    => Boolean
  })

  $num_pcie_ports = lookup('ntnuopenstack::nova::num_pcie_ports', {
    'default_value' => 28,
    'value_type'    => Integer[0,28],
  })

  $slversion = lookup('profile::shiftleader::major::version', {
    'default_value' => 1,
    'value_type'    => Integer,
  })

  $workarounds = lookup('ntnuopenstack::nova::workarounds', {
    'default_value' => undef,
    'value_type'    => Optional[Array[String]],
  })

  if($slversion == 1) {
    $management_if = lookup('profile::interfaces::management')
    $management_ip = getvar("::ipaddress_${management_if}")
  } else {
    $management_ip = $::sl2['server']['primary_interface']['ipv4']
  }

  require ::ntnuopenstack::nova::compute::base
  require ::ntnuopenstack::repo

  $cpu_model_extra_flags = $nova_nested_virt ? {
    true  => 'vmx',
    false => undef
  }

  if($localdisk) {
    $type = lookup('ntnuopenstack::compute::disk::type', {
      'default_value' => 'filesystem',
      'value_type'    => Enum['filesystem', 'lvm'],
    })

    if ( $type == 'filesystem' ) {
      require ::ntnuopenstack::nova::compute::disk::filesystem
      $images_type = 'qcow2'
    } else {
      require ::ntnuopenstack::nova::compute::disk::lvm
      $images_type = 'lvm'
    }
  } else {
    $images_type = 'rbd'
  }

  if($cpu_model) {
    $cpuconfig = {
      cpu_mode          => 'custom',
      cpu_models        => [ $cpu_model ] + $cpu_models,
      migration_support => true,
    }
  } else {
    $cpuconfig = {
      cpu_mode => 'host-passthrough',
    }
  }

  if($workarounds) {
    class { '::ntnuopenstack::nova::workarounds':
      workarounds => $workarounds
    }
  }

  class { '::nova::compute::libvirt':
    cpu_model_extra_flags => $cpu_model_extra_flags,
    disk_cachemodes       => [ 'network=writeback' ],
    hw_machine_type       => $machine_type,
    vncserver_listen      => $management_ip,
    images_type           => $images_type,
    num_pcie_ports        => $num_pcie_ports,
    *                     => $cpuconfig,
  }

  class { '::ntnuopenstack::nova::compute::ceph':
    ephemeral_storage => ! $localdisk,
  }

  class { '::profile::services::libvirt::architectures':
    require => Class['::nova::compute::libvirt'],
    notify  => Service['libvirt'],
  }
}
