# Configure firewall rules for haproxy-barbican
class ntnuopenstack::barbican::firewall::haproxy {
  ::profile::baseconfig::firewall::service::global { 'barbican-API':
    protocol => 'tcp',
    port     => 9311,
  }
}
