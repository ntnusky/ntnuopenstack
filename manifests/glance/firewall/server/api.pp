# Configures the firewall to accept incoming traffic to the glance API. 
class ntnuopenstack::glance::firewall::server::api {
  ::profile::firewall::infra::region { 'Glance-API':
    port => 9292,
  }
}
