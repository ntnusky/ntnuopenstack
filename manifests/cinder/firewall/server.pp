# Configures the firewall to accept incoming traffic to the cinder API. 
class ntnuopenstack::cinder::firewall::server {
  ::profile::firewall::infra::region { 'Cinder-API':
    port     => 8776,
  }
}
