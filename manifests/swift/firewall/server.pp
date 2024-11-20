# Configures the firewall to accept incoming traffic to the swift API. 
class ntnuopenstack::swift::firewall::server {
  ::profile::firewall::infra::region { 'Swift-API':
    port => 7480,
  }
}
