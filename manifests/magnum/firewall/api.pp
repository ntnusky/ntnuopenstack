# Configure firewall rules for magnum API
class ntnuopenstack::magnum::firewall::api {
  ::profile::baseconfig::firewall::service::infra { 'magnum API':
    protocol => 'tcp',
    port     => 9511,
  }
}
