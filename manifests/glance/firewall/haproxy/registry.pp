# Configures the firewall to accept incoming traffic to the glance registry API. 
class ntnuopenstack::glance::firewall::haproxy::registry {
  ::profile::baseconfig::firewall::service::infra { 'Glance-Registry':
    protocol => 'tcp',
    port     => 9191,
  }
}
