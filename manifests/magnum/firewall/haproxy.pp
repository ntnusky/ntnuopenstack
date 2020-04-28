# Configure firewall rules for haproxy-magnum
class ntnuopenstack::magnum::firewall::haproxy {
  ::profile::baseconfig::firewall::service::global { 'magnum-API':
    protocol => 'tcp',
    port     => 9511,
  }
}
