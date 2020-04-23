# Configure firewall rules for barbican API
class ntnuopenstack::barbican::firewall::api {
  ::profile::baseconfig::firewall::service::infra { 'barbican API':
    protocol => 'tcp',
    port     => 9311,
  }
}
