# Configures the firewall to pass incoming traffic to the heat API.
class ntnuopenstack::heat::firewall::api {
  ::profile::baseconfig::firewall::service::infra { 'Heat-API':
    protocol => 'tcp',
    port     => [8000,8004],
  }
}
