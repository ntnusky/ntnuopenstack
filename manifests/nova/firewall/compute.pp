# Configures firewall rules specific for compute nodes
class ntnuopenstack::nova::firewall::compute {
  ::profile::baseconfig::firewall::service::infra { 'Libvirt-migration':
    protocol => 'tcp',
    port     => 16509,
  }
  ::profile::baseconfig::firewall::service::infra { 'QEMU-migration':
    protocol => 'tcp',
    port     => '49152-49215',
  }
  ::profile::baseconfig::firewall::service::infra { 'QEMU-VNC':
    protocol => 'tcp',
    port     => '5900-5999',
  }
}
