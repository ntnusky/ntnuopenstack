# Configures firewall rules specific for compute nodes
class ntnuopenstack::nova::firewall::compute {
  ::profile::firewall::infra::region { 'LiveMigration-SSH':
    port => 22,
  }
  ::profile::firewall::infra::region { 'LiveMigration-Libvirt':
    port     => 16509,
  }
  ::profile::firewall::infra::region { 'LiveMigration-QEMU':
    port     => '49152-49215',
  }
  ::profile::firewall::infra::region { 'QEMU-VNC':
    port     => '5900-5999',
  }
}
