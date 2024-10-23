# Performs basic designate configuration.
class ntnuopenstack::designate::base {
  require ::ntnuopenstack::designate::dbconnection
  include ::ntnuopenstack::designate::firewall::api
  include ::ntnuopenstack::designate::firewall::dns

  # RabbitMQ connection-information
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Array[String], Boolean],
    'default_value' => false,
  })

  if ($rabbitservers) {
    $ha_transport_conf = {
      rabbit_ha_queues    => true,
      amqp_durable_queues => true,
    }
  } else {
    $ha_transport_conf = {}
  }

  $transport_url = lookup('ntnuopenstack::transport::url')

  class { '::designate':
    default_transport_url => $transport_url,
    *                     => $ha_transport_conf,
  }

  include designate::central
  include designate::client

  class { 'designate::producer':
    workers => 2,
  }

  class { 'designate::worker':
    workers => 2,
  }
}
