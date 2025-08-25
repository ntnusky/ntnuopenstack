# Designate publishing nameserver (NS) running bind9
class ntnuopenstack::designate::ns {
  include ::ntnuopenstack::designate::firewall::dns
  include ::ntnuopenstack::designate::firewall::rndc

  $api_servers = lookup('ntnuopenstack::designate::api_servers', Array[Stdlib::IP::Address]);
  $transfer_addresses = lookup('ntnuopenstack::designate::transfer_addresses', Array[String]);
  $infra_all = lookup('profile::networks::infra::all', {
    'value_type'   => Array[String],
    'default_value' => [],
  });

  $allow_transfer = join($api_servers + $transfer_addresses + $infra_all, '; ');

  class {'dns':
    recursion          => 'no',
    allow_recursion    => [],
    listen_on          => 'any',
    listen_on_v6       => 'any',
    localzonepath      => 'unmanaged',
    additional_options => {
      'auth-nxdomain'     => 'no',
      'allow-new-zones'   => 'yes',
      'allow-notify'      => "{ ${join($api_servers, '; ')}; }",
      'allow-update'      => "{ ${join($api_servers, '; ')}; }",
      'allow-transfer'    => "{ ${allow_transfer}; }",

      # https://docs.openstack.org/designate/latest/admin/production-guidelines.html#bind9-mitigation
      'minimal-responses' => 'yes',
    },
    controls           => {
      '*' => {
        'port'              => 953,
        'allowed_addresses' => $api_servers,
        'keys'              => ['designate-rndc-key'],
      }
    },
  }

  dns::key {'designate-rndc-key':
    secret   => lookup('ntnuopenstack::designate::rndc_key', String),
  }
}
