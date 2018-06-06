# Installs and configures the neutron agents
class ntnuopenstack::neutron::agents {
  $adminlb_ip = hiera('ntnuopenstack::endpoint::admin::ipv4', undef)
  $admin_ip = hiera('profile::api::neutron::admin::ip', undef)
  $dns_servers = hiera('ntnuopenstack::neutron::dns')
  $neutron_vrrp_pass = hiera('ntnuopenstack::neutron::vrrp_pass')
  $nova_metadata_secret = hiera('ntnuopenstack::nova::sharedmetadataproxysecret')

  require ::ntnuopenstack::neutron::base
  require ::ntnuopenstack::neutron::firewall::l3agent
  require ::ntnuopenstack::repo

  class { '::neutron::agents::metadata':
    shared_secret => $nova_metadata_secret,
    metadata_ip   => pick($adminlb_ip, $admin_ip),
    enabled       => true,
  }

  class { '::neutron::agents::dhcp':
    dnsmasq_dns_servers => $dns_servers,
  }

  class { '::neutron::agents::l3':
    ha_enabled            => true,
    ha_vrrp_auth_password => $neutron_vrrp_pass,
  }
}
