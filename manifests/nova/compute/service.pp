# This class installs and configures the nova-compute service for a compute-node.
class ntnuopenstack::nova::compute::service {
  # Determine the VNCProxy-settings
  $host = lookup('ntnuopenstack::nova::vncproxy::host')
  $port = lookup('ntnuopenstack::nova::vncproxy::port', {
    'default_value' => 6080,
    'value_type'    => Integer,
  })
  $cert = lookup('ntnuopenstack::endpoint::public::cert', {
    'default_value' => false,
  })

  $management_if = lookup('profile::interfaces::management', {
    'default_value' => $::sl2['server']['primary_interface']['name'],
    'value_type'    => String,
  })
  $management_ip = getvar("::ipaddress_${management_if}")

  require ::ntnuopenstack::nova::compute::base
  require ::ntnuopenstack::repo

  if($cert) {
    $protocol = 'https'
  } else {
    $protocol = 'http'
  }

  class { '::nova::compute':
    enabled                          => true,
    block_device_allocate_retries    => 120,
    vnc_enabled                      => true,
    vncserver_proxyclient_address    => $management_ip,
    vncproxy_host                    => $host,
    vncproxy_protocol                => $protocol,
    vncproxy_port                    => $port,
    resume_guests_state_on_host_boot => true,
  }

  user { 'nova':
    shell => '/bin/bash',
    home  => '/var/lib/nova',
  }

  # TODO: Why do we need this?
  $pymysql_pkg = $::osfamily ? {
    'RedHat' => 'python2-PyMySQL',
    'Debian' => 'python3-pymysql',
    default  => '',
  }

  ensure_packages( [$pymysql_pkg] , {
    'ensure' => 'present',
  })
}

