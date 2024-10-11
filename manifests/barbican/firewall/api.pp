# Configure firewall rules for barbican API
class ntnuopenstack::barbican::firewall::api {
  ::profile::firewall::infra::region { 'barbican API':
    port => 9311,
  }
}
