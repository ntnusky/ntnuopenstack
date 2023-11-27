# Performs common base-configuration of nova.
class ntnuopenstack::nova::common::base (
  Hash    $extra_options = {},
){
  include ::ntnuopenstack::nova::common::placement
  include ::ntnuopenstack::nova::common::sudo

  # Determine if quotas should be counted through placement
  $placement_quota = lookup('ntnuopenstack::nova::quota::placement', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

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
    default_transport_url      => $transport_url,
    count_usage_from_placement => $placement_quota,
    *                          => $ha_transport_conf + $extra_options,
  }
}
