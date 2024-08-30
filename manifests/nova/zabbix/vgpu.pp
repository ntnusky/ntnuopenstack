# Zabbix config needed to monitor Nvidia VGPUs
class ntnuopenstack::nova::zabbix::vgpu {

  file { '/usr/local/sbin/get-vgpu-data.py':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/zabbix/get-vgpu-data.py',
  }

  file { '/usr/lib/python3/dist-packages/zabbix_vgpu.py':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/profile/zabbix/zabbix_vgpu.py',
  }

  zabbix::userparameters { 'vgpu':
    content => 'UserParameter=vgpu.data,/usr/local/sbin/get-vgpu-data.py',
  }

  zabbix::userparameters { 'nvidia_gpus':
    content => join([
      "UserParameter=gpu.discovery,nvidia-smi --query-gpu=gpu_bus_id,name,driver_version --format=csv,noheader,nounits | sed -e 's/, /,/g'",
      "UserParameter=gpu.card[*],nvidia-smi --query-gpu=temperature.gpu,memory.total,memory.used,fan.speed,utilization.gpu,power.draw --format=csv,noheader,nounits -i \$1 | sed -e 's/, /,/g'",
    ], "\n"),
  }
}
