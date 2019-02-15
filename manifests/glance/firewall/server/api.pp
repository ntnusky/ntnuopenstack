# Configures the firewall to accept incoming traffic to the glance API. 
class ntnuopenstack::glance::firewall::server::api {
  ::profile::baseconfig::firewall::service::infra { 'Glance-API':
    protocol => 'tcp',
    port     => 9292,
  }
}
