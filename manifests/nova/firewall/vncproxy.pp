# Configures the firewall to accept vncproxy connections
class ntnuopenstack::nova::firewall::vncproxy {
  ::profile::firewall::infra::region { 'Noca-VNCProxy':
    port => 6080,
  }
}
