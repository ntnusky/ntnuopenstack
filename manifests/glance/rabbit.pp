# Glance rabbit configuration 
class ntnuopenstack::glance::rabbit {
  $transport_url = lookup('ntnuopenstack::transport::url', String)
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  if ($rabbitservers) {
    $ha_transport_conf = {
      rabbit_qos_prefetch_count     => 1,
      rabbit_quorum_queue           => true,
      rabbit_transient_quorum_queue => true,
      rabbit_stream_fanout          => true,
      rabbit_use_queue_manager      => true,
    }
  } else {
    $ha_transport_conf = {}
  }

  class { '::glance::notify::rabbitmq':
    default_transport_url => $transport_url,
    *                     => $ha_transport_conf,
  }
}
