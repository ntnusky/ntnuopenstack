# Configures the firewall to accept incoming traffic to the swift API. 
class ntnuopenstack::swift::firewall::server {
  ::profile::baseconfig::firewall::service::infra { 'Swift-API':
    protocol => 'tcp',
    port     => 7480,
  }
}
