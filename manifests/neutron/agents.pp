# Installs and configures the neutron agents
class ntnuopenstack::neutron::agents {
  $metadata_ip = lookup('ntnuopenstack::endpoint::admin::ipv4', {
    'value_type' => Stdlib::IP::Address,
  })
  $dns_servers = lookup('ntnuopenstack::neutron::dns', {
    'value_type' => Array[Stdlib::IP::Address],
    'merge'      => 'unique',
  })
  $neutron_vrrp_pass = lookup('ntnuopenstack::neutron::vrrp_pass', String)
  $metadata_secret = lookup('ntnuopenstack::nova::sharedmetadataproxysecret',
                            String)
  require ::ntnuopenstack::neutron::base
  require ::ntnuopenstack::repo

  class { '::neutron::agents::metadata':
    shared_secret => $metadata_secret,
    metadata_host => $metadata_ip,
    enabled       => true,
  }

  class { '::neutron::agents::dhcp':
    dnsmasq_dns_servers => $dns_servers,
  }

  class { '::neutron::agents::l3':
    ha_vrrp_auth_password => $neutron_vrrp_pass,
    extensions            => 'port_forwarding', 
  }
}
