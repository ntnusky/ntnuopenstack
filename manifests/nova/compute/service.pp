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

  $slversion = lookup('profile::shiftleader::major::version', {
    'default_value' => 1,
    'value_type'    => Integer,
  })

  if($slversion == 1) {
    $management_if = lookup('profile::interfaces::management')
    $management_ip = getvar("::ipaddress_${management_if}")
  } else {
    $management_ip = $::sl2['server']['primary_interface']['ipv4']
  }

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

