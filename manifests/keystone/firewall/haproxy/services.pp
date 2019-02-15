# Opens the firewall for the keystone port from any source
class ntnuopenstack::keystone::firewall::haproxy::services {
  ::profile::baseconfig::firewall::service::global { 'Keystone-Public':
    protocol => 'tcp',
    port     => 5000,
  }
}
