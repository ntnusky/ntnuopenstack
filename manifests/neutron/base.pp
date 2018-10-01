# Installs the base neutron services.
class ntnuopenstack::neutron::base {
  $service_plugins = hiera('ntnuopenstack::neutron::service_plugins')
  $mtu = hiera('ntnuopenstack::neutron::mtu', undef)
  $rabbitservers = hiera('profile::rabbitmq::servers', false)
  $transport_url = hiera('ntnuopenstack::transport::url')

  require ::ntnuopenstack::repo
  include ::ntnuopenstack::neutron::sudo

  if ($rabbitservers) {
    $ha_transport_conf = {
      rabbit_ha_queues    => true,
      amqp_durable_queues => true,
    }
  } else {
    $ha_transport_conf = {}
  }

  class { '::neutron':
    allow_overlapping_ips   => true,
    core_plugin             => 'ml2',
    default_transport_url   => $transport_url,
    dhcp_agents_per_network => 2,
    global_physnet_mtu      => $mtu,
    service_plugins         => $service_plugins,
    *                       => $ha_transport_conf,
  }

  neutron_config { 'DEFAULT/max_routes':
    value => 100,
  }
}
