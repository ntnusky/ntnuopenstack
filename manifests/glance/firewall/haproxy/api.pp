# Configures the firewall to accept incoming traffic to the glance API. 
class ntnuopenstack::glance::firewall::haproxy::api {
  ::profile::baseconfig::firewall::service::global { 'Glance-API':
    protocol => 'tcp',
    port     => 9292,
  }
}
