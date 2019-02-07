# Configures the firewall to accept vncproxy connections
class ntnuopenstack::nova::firewall::vncproxy {
  ::profile::baseconfig::firewall::service::infra { 'Noca-VNCProxy':
    protocol => 'tcp',
    port     => 6080,
  }
}
