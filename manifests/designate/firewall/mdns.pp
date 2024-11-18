# Configures firewall rules for mdns for designate::api
class ntnuopenstack::designate::firewall::mdns {
  ::profile::baseconfig::firewall::service::infra { 'designate mdns':
    protocol => 'tcp',
    port     => 5354,
  }
}
