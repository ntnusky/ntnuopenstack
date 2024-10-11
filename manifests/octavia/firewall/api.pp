# Configures firewall rules for the octavia API 
class ntnuopenstack::octavia::firewall::api {
  $api_port = lookup('ntnuopenstack::octavia::api::port')

  ::profile::firewall::infra::region { 'octavia API':
    port => $api_port,
  }
}
