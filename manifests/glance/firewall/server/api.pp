# Configures the firewall to accept incoming traffic to the glance API. 
class ntnuopenstack::glance::firewall::server::api {
  $managementnet = hiera('profile::networks::management::ipv4::prefix')

  require ::profile::baseconfig::firewall

  firewall { '500 accept Glance API':
    source => $managementnet,
    proto  => 'tcp',
    dport  => '9292',
    action => 'accept',
  }
}
