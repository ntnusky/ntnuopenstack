# Configures firewall rules for the designate API 
class ntnuopenstack::designate::firewall::api {
  $api_port = lookup('ntnuopenstack::designate::api::port')

  ::profile::firewall::infra::all { 'designate API':
    port     => $api_port,
  }
}
