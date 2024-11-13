# Designate publishing nameserver (NS) running bind9
class ntnuopenstack::designate::ns {
  require ::ntnuopenstack::repo
  include ::ntnuopenstack::designate::firewall::dns
  include ::ntnuopenstack::designate::firewall::rndc

  $designate_api_servers = lookup('ntnuopenstack::designate::api_servers', Array[Stdlib::IP::Address]);
  $listen_on = 'any';
  $listen_on_v6 = 'any';

  class {'dns':
    recursion          => 'no',
    allow_recursion    => [],
    listen_on_v6       => false, # Overwritten by additional_options
    additional_options => {
      'listen-on'         => "port 53 { ${listen_on}; }",
      'listen-on-v6'      => "port 53 { ${listen_on_v6}; }",
      # TODO: allow-notify / allow-update from allowlist
      'auth-nxdomain'     => 'no',
      'allow-new-zones'   => 'yes',

      # https://docs.openstack.org/designate/latest/admin/production-guidelines.html#bind9-mitigation
      'minimal-responses' => 'yes',
    },
    controls           => {
      '*' => {
        'port'              => 953,
        'allowed_addresses' => $designate_api_servers,
        'keys'              => ['designate-rndc-key'],
      }
    },
  }

  dns::key {'designate-rndc-key':
    secret   => lookup('ntnuopenstack::designate::rndc_key', String),
  }
}
