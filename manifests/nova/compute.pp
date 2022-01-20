# This class installs and configures nova for a compute-node.
class ntnuopenstack::nova::compute {
  # Determine the VNCProxy-settings
  $host = lookup('ntnuopenstack::nova::vncproxy::host')
  $port = lookup('ntnuopenstack::nova::vncproxy::port', {
    'default_value' => 6080,
    'value_type'    => Integer,
  })
  $cert = lookup('ntnuopenstack::endpoint::public::cert', {
    'default_value' => false,
  })

  $management_if = lookup('profile::interfaces::management')
  $management_ip = getvar("::ipaddress_${management_if}")

  require ::ntnuopenstack::nova::compute::base
  contain ::ntnuopenstack::nova::compute::libvirt
  contain ::ntnuopenstack::nova::common::neutron
  include ::ntnuopenstack::nova::munin::compute
  require ::ntnuopenstack::repo

  if($cert) {
    $protocol = 'https'
  } else {
    $protocol = 'http'
  }

  class { '::nova::compute':
    enabled                          => true,
    vnc_enabled                      => true,
    vncserver_proxyclient_address    => $management_ip,
    vncproxy_host                    => $host,
    vncproxy_protocol                => $protocol,
    vncproxy_port                    => $port,
    resume_guests_state_on_host_boot => true,
  }

  class { '::ntnuopenstack::nova::compute::ceph':
    ephemeral_storage => true,
  }

  user { 'nova':
    shell => '/bin/bash',
    home  => '/var/lib/nova',
  }

  $install_sensu = lookup('profile::sensu::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })
  if ($install_sensu) {
    sensu::subscription { 'os-compute': }
  }

  $pymysql_pkg = $::osfamily ? {
    'RedHat' => 'python2-PyMySQL',
    'Debian' => 'python3-pymysql',
    default  => '',
  }

  ensure_packages( [$pymysql_pkg] , {
    'ensure' => 'present',
  })
}

