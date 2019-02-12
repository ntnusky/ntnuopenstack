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
  $nova_uuid = lookup('ntnuopenstack::nova::ceph::uuid')

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::nova::base::compute
  contain ::ntnuopenstack::nova::ceph
  contain ::ntnuopenstack::nova::neutron
  contain ::ntnuopenstack::nova::libvirt
  include ::ntnuopenstack::nova::munin::compute

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

  user { 'nova':
    shell => '/bin/bash',
    home  => '/var/lib/nova',
  }

  class { '::nova::compute::rbd':
    libvirt_rbd_user        => 'nova',
    libvirt_images_rbd_pool => 'volumes',
    libvirt_rbd_secret_uuid => $nova_uuid,
    manage_ceph_client      => false,
  }
}

