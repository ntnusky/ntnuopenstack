# Configures the firewall to pass incoming traffic to the heat API.
class ntnuopenstack::heat::firewall::api {
  ::profile::firewall::infra::region { 'Heat-API':
    port     => [8000,8004],
  }
}
