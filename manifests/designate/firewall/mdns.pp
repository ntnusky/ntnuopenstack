# Configures firewall rules for mdns for designate::api
class ntnuopenstack::designate::firewall::mdns {
  ::profile::firewall::custom { 'designate mdns TCP':
    hiera_key          => 'ntnuopenstack::designate::ns_servers',
    port               => 5354,
    transport_protocol => 'tcp',
  }
  ::profile::firewall::custom { 'designate mdns UDP':
    hiera_key          => 'ntnuopenstack::designate::ns_servers',
    port               => 5354,
    transport_protocol => 'udp',
  }
}
