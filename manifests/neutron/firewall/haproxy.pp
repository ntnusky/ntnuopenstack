# Configures the firewall to accept incoming traffic to the neutron API. 
class ntnuopenstack::neutron::firewall::haproxy {
  ::profile::baseconfig::firewall::service::global { 'Neutron-API':
    protocol => 'tcp',
    port     => 9696,
  }
}
