# Configure nova-compute to expose a vGPU
class ntnuopenstack::nova::vgpu {
  include ::profile::monitoring::munin::plugin::vgpu

  # This is just a mechanism to ensure that this key is actually defined,
  # and otherwise fail the puppet run.
  $vgpu_type = lookup('nova::compute::vgpu::vgpu_types_device_addresses_mapping', Hash)

  # Ensure SR-IOV virtual functions are enabled on boot
  # This has no effect on GPUs that don't support SR-IOV

  $sriov_cmd = '/usr/lib/nvidia/sriov-manage -e ALL'

  cron { 'Enable SR-IOV for Nvidia GPUs on reboot':
    command     => $sriov_cmd,
    environment => 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin',
    user        => 'root',
    special     => 'reboot',
  }

  # This can be removed when nova bug #1906494 is fixed
  file_line { 'sriov-manage':
    ensure => present,
    path   => '/usr/lib/nvidia/sriov-manage',
    line   => 'local numvfs=2',
    match  => 'local numvfs=\$2',
    notify => Exec['sriov-manage-firstrun'],
  }

  exec { 'sriov-manage-firstrun':
    command     => $sriov_cmd,
    user        => 'root',
    refreshonly => true,
  }
}
