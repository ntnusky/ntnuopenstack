# Installs the base neutron services.
class ntnuopenstack::neutron::base {
  $service_plugins = lookup('ntnuopenstack::neutron::service_plugins', {
    'value_type'    => Array[String],
    'default_value' => [
      'router',
      'firewall',
      'neutron_lbaas.services.loadbalancer.plugin.LoadBalancerPluginv2',
    ],
  })
  $mtu = lookup('ntnuopenstack::neutron::mtu', {
    'value_type'    => Variant[Undef, Integer],
    'default_value' => undef,
  })
  $transport_url = lookup('ntnuopenstack::transport::url', String)
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

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
