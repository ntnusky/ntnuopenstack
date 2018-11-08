# Configures firewall rules specific for compute nodes
class ntnuopenstack::nova::firewall::compute {
  $managementv4 = hiera('profile::networks::management::ipv4::prefix', false)
  $managementv6 = hiera('profile::networks::management::ipv6::prefix', false)

  require ::profile::baseconfig::firewall

  if($managementv4) {
    firewall { '500 accept libvirtd connection for migration':
      source => $managementv4,
      proto  => 'tcp',
      dport  => '16509',
      action => 'accept',
    }
    firewall { '501 accept qemu migration ports':
      source => $managementv4,
      proto  => 'tcp',
      dport  => '49152-49215',
      action => 'accept',
    }
  }
  if($managementv6) {
    firewall { '500 ipv6 accept libvirtd connection for migration':
      source   => $managementv6,
      proto    => 'tcp',
      dport    => '16509',
      action   => 'accept',
      provider => 'ip6tables',
    }
    firewall { '501 ipv6 accept qemu migration ports':
      source   => $managementv6,
      proto    => 'tcp',
      dport    => '49152-49215',
      action   => 'accept',
      provider => 'ip6tables',
    }
  }
}
