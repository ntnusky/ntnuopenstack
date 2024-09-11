# Installs and configures the octavia controller services
class ntnuopenstack::octavia::controller {
  $flavor_id = lookup('ntnuopenstack::octavia::flavor::id', String)
  $image_tag = lookup('ntnuopenstack::octavia::image::tag', String, undef,
                      'amphora')
  $secgroup_id = lookup('ntnuopenstack::octavia::secgroup::id', String)
  $network_id = lookup('ntnuopenstack::octavia::network::id', String)
  $keypair = lookup('ntnuopenstack::octavia::ssh::keypair::name', String)
  $heartbeat_key = lookup('ntnuopenstack::octavia::heartbeat::key', String)
  $health_managers = lookup('ntnuopenstack::octavia::health::managers',
                        Array[String])
  $controller_ip_port_list = join($health_managers, ', ')
  $management_if = lookup('profile::interfaces::management', {
    'default_value' => $::sl2['server']['primary_interface']['name'],
    'value_type'    => String,
  })
  $mip = $facts['networking']['interfaces'][$management_if]['ip']
  $management_ipv4 = lookup(
    "profile::baseconfig::network::interfaces.${management_if}.ipv4.address", {
      'value_type'    => Stdlib::IP::Address::V4,
      'default_value' => $mip,
  })
  $installmunin = lookup('profile::munin::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })


  include ::ntnuopenstack::octavia::base
  require ::ntnuopenstack::octavia::dbconnection
  include ::ntnuopenstack::octavia::firewall::controller
  require ::ntnuopenstack::repo

  if($installmunin {
    include ::profile::monitoring::munin::plugin::openstack::octavia
  }

  class { '::octavia::controller':
    amp_boot_network_list   => [$network_id],
    amp_flavor_id           => $flavor_id,
    amp_image_tag           => $image_tag,
    amp_secgroup_list       => [$secgroup_id],
    amp_ssh_key_name        => $keypair,
    controller_ip_port_list => $controller_ip_port_list,
    heartbeat_key           => $heartbeat_key,
    loadbalancer_topology   => 'SINGLE',
  }

  class { '::octavia::worker':
    manage_nova_flavor => false,
    amp_project_name   => 'services',
  }

  class { '::octavia::health_manager':
    ip            => $management_ipv4,
  }

  class { '::octavia::housekeeping':
  }
}
