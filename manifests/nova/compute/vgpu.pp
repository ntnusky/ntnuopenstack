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
  $sriov_cmd = '/usr/lib/nvidia/sriov-manage'

  cron { 'Enable SR-IOV for Nvidia GPUs on reboot':
    ensure => 'absent',
  }

  systemd::manage_unit { 'nvidia-sriov-manage@.service':
    enable        => true,
    active        => true,
    unit_entry    => {
      'After'       => ['nvidia-vgpu-mgr.service', 'nvidia-vgpud.service'],
      'Description' => 'Enable Nvidia GPU virtual functions'
    },
    service_entry => {
      'Type'              => 'oneshot',
      'User'              => 'root',
      'Group'             => 'root',
      'ExecStart'         => "${sriov_cmd} -e %i",
      'TimeOutSec'        => '120',
      'Slice'             => 'system.slice',
      'CPUAccounting'     => 'True',
      'BlockIOAccounting' => 'True',
      'MemoryAccounting'  => 'True',
      'TasksAccounting'   => 'True',
      'RemainAfterExit'   => 'True',
      'ExecStartPre'      => '/usr/bin/sleep 30',
    },
    install_entry => {
      'WantedBy'  => 'multi-user.target',
    },
  }

  exec { 'sriov-manage-firstrun':
    command     => "${sriov_cmd} -e ALL",
    user        => 'root',
    refreshonly => true,
  }
}
