# Configures firewall rules for the designate API 
class ntnuopenstack::designate::firewall::api {
  $api_port = lookup('ntnuopenstack::designate::api::port')

  ::profile::baseconfig::firewall::service::infra { 'designate API':
    protocol => 'tcp',
    port     => $api_port,
  }
}
