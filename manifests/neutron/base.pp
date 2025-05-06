# Installs the base neutron services.
class ntnuopenstack::neutron::base {
  $service_plugins = lookup('ntnuopenstack::neutron::service_plugins', {
    'value_type'    => Array[String],
    'default_value' => ['router', 'port_forwarding'],
  })
  $mtu = lookup('ntnuopenstack::neutron::mtu', {
    'value_type'    => Variant[Undef, Integer],
    'default_value' => undef,
  })
  $max_routes = lookup('ntnuopenstack::neutron::routes::max', {
    'default_value' => 100,
    'value_type'    => Integer,
  })
  $transport_url = lookup('ntnuopenstack::transport::url', String)
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  $dns_domain = lookup('ntnuopenstack::neutron::dns::domain', {
    'default_value' => 'openstack.local',
    'value_type'    => String,
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
    core_plugin             => 'ml2',
    default_transport_url   => $transport_url,
    dhcp_agents_per_network => 2,
    global_physnet_mtu      => $mtu,
    service_plugins         => $service_plugins,
    dns_domain              => $dns_domain,
    *                       => $ha_transport_conf,
  }

  neutron_config { 'DEFAULT/max_routes':
    value => $max_routes,
  }
}
