# Performs common base-configuration of nova.
class ntnuopenstack::nova::common::base (
  Hash    $extra_options = {},
){
  include ::ntnuopenstack::nova::common::glance
  include ::ntnuopenstack::nova::common::placement
  include ::ntnuopenstack::nova::common::sudo

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

  class { '::nova':
    default_transport_url => $transport_url,
    *                     => $ha_transport_conf + $extra_options,
  }
}
