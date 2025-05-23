# Configure nova-compute to expose a vGPU
class ntnuopenstack::nova::compute::vgpu {
  # The variable mdev_type is just a mechanism to ensure that this key is
  # actually defined, and otherwise fail the puppet run. So, it is nice to have
  # here even though this class is not using it...
  $mdev_type = lookup('nova::compute::mdev::mdev_types', Hash)

  $zabbix_servers = lookup('profile::zabbix::agent::servers', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::Nosubnet],
  })

  if($zabbix_servers =~ Array[Stdlib::IP::Address::Nosubnet, 1]) {
    include ::ntnuopenstack::nova::zabbix::vgpu
  }

  # Ensure SR-IOV virtual functions are enabled on boot
  # This has no effect on GPUs that don't support SR-IOV
  $sriov_cmd = '/usr/lib/nvidia/sriov-manage -e ALL'
  cron { 'Enable SR-IOV for Nvidia GPUs on reboot':
    command     => $sriov_cmd,
    environment => 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin',
    user        => 'root',
    special     => 'reboot',
    notify      => Exec['sriov-manage-firstrun'],
  }

  exec { 'sriov-manage-firstrun':
    command     => $sriov_cmd,
    user        => 'root',
    refreshonly => true,
  }
}
