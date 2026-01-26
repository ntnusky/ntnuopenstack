# Define a systemd service that set the desired VGPU types on correct VFs
class ntnuopenstack::nova::compute::vgpu::types {
  $types = lookup('ntnuopenstack::nova::vgpu::types', Array[Hash])
  $execstart = $types.map |$e| {
    $type = $e['type']
    $address = stdlib::shell_escape($e['address'])
    $path = "/sys/bus/pci/devices/${address}/nvidia/current_vgpu_type"
    "/usr/bin/bash -c '[ $(cat ${path}) -eq ${type} ] || /usr/bin/echo ${type} > ${path}'"
  }

  systemd::manage_unit { 'set-vgpu-types.service':
    enable        => true,
    active        => true,
    path          => '/lib/systemd/system',
    unit_entry    => {
      'After'       => 'nvidia-sriov-manage@ALL.service',
      'Before'      => 'nova-compute.service',
      'Description' => 'Create vgpu types on the defined VFs in nova-compute'
    },
    service_entry => {
      'Type'            => 'oneshot',
      'User'            => 'root',
      'Group'           => 'root',
      'ExecStart'       => $execstart,
      'RemainAfterExit' => true,
    },
    install_entry => {
      'WantedBy' => 'multi-user.target',
    }
  }
}
