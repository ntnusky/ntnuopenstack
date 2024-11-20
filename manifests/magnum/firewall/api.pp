# Configure firewall rules for magnum API
class ntnuopenstack::magnum::firewall::api {
  ::profile::firewall::infra::region { 'magnum API':
    port => 9511,
  }
}
