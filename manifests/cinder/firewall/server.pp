# Configures the firewall to accept incoming traffic to the cinder API. 
class ntnuopenstack::cinder::firewall::server {
  ::profile::baseconfig::firewall::service::infra { 'Cinder-API':
    protocol => 'tcp',
    port     => 8776,
  }
}
