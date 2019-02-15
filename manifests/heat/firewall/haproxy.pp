# Configures the firewall to accept incoming traffic to the heat API. 
class ntnuopenstack::heat::firewall::haproxy {
  ::profile::baseconfig::firewall::service::global { 'Heat-API':
    protocol => 'tcp',
    port     => [8000,8004],
  }
}
