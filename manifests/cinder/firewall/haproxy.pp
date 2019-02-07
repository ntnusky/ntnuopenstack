# Configures the firewall to accept incoming traffic to the cinder API. 
class ntnuopenstack::cinder::firewall::haproxy {
  ::profile::baseconfig::firewall::service::global { 'Cinder-API':
    protocol => 'tcp',
    port     => 8776,
  }
}
