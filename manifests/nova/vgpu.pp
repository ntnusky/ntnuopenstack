# Configure nova-compute to expose a vGPU
# This is just a mechanism to ensure that this key is actually defined,
# and otherwise fail the puppet run.
class ntnuopenstack::nova::vgpu {
  $vgpu_type = lookup('nova::compute::vgpu::vgpu_types_device_addresses_mapping', Hash)

  # Ensure SR-IOV virtual functions are enabled on boot
  # This has no effect on GPUs that don't support SR-IOV

  cron { 'Enable SR-IOV for Nvidia GPUs on reboot':
    command => '/usr/lib/nvidia/sriov-manage -e ALL',
    user    => 'root',
    special => 'reboot',
  }

  # This can be removed when nova bug #1906494 is fixed
  file_line { 'sriov-manage':
    ensure => present,
    path   => '/usr/lib/nvidia/sriov-manage',
    line   => 'local numvfs=2',
    match  => 'local numvfs=\$2',
  }
}
