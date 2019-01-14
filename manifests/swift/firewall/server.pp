# Configures the firewall to accept incoming traffic to the swift API. 
class ntnuopenstack::swift::firewall::server {
  $managementnet = hiera('profile::networks::management::ipv4::prefix')

  require ::profile::baseconfig::firewall

  firewall { '500 accept Swift API':
    source => $managementnet,
    proto  => 'tcp',
    dport  => '8080',
    action => 'accept',
  }
}
