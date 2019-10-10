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
  $bgp_routerID = lookup('ntnuopenstack::neutron::bgp::router::id', {
    'value_type'    => Stdlib::IP::Address,
    'default_value' => '0.0.0.0',
  })

  require ::ntnuopenstack::neutron::base
  require ::ntnuopenstack::neutron::firewall::l3agent
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
    ha_enabled            => true,
    ha_vrrp_auth_password => $neutron_vrrp_pass,
    extensions            => 'fwaas_v2,port_forwarding',
  }

  if($bgp_routerID != '0.0.0.0') {
    ::neutron::agents::bgp_dragent {
      bgp_router_id => $bgp_routerID,
    }
  }
}
