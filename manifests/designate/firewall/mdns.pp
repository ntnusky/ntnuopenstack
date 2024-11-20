# Configures firewall rules for mdns for designate::api
class ntnuopenstack::designate::firewall::mdns {
  ::profile::firewall::custom { 'designate mdns':
    hiera_key => 'ntnuopenstack::designate::ns_servers',
    port      => 5354,
  }
}
