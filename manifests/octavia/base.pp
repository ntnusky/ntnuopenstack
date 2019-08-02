# Performs basic octavia configuration.
class ntnuopenstack::octavia::base {
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

  require ::ntnuopenstack::repo

  class { '::octavia':
    default_transport_url => $transport_url,
    *                     => $ha_transport_conf,
  }
}
