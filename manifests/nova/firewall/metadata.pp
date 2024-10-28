# Configures the firewall to accept metadata-requests 
class ntnuopenstack::nova::firewall::metadata {
  ::profile::firewall::infra::region { 'Nova-Metadata':
    port => 8775,
  }
}
