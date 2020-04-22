# Configures firewall rules for the octavia API 
class ntnuopenstack::octavia::firewall::api {
  $api_port = lookup('ntnuopenstack::octavia::api::port', Stdlib::Port)

  ::profile::baseconfig::firewall::service::infra { 'octavia API':
    protocol => 'tcp',
    port     => $api_port,
  }
}
