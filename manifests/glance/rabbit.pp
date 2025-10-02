# Glance rabbit configuration 
class ntnuopenstack::glance::rabbit {
  $transport_url = lookup('ntnuopenstack::transport::url', String)
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  if ($rabbitservers) {
    $ha_transport_conf = {
      rabbit_quorum_queue           => true,
      rabbit_transient_quorum_queue => true,
    }
  } else {
    $ha_transport_conf = {}
  }

  class { '::glance::notify::rabbitmq':
    default_transport_url => $transport_url,
    *                     => $ha_transport_conf,
  }

  # TODO: Monitor when this becomes a parameter in ::glance::notify::rabbitmq
  glance_config {
    'oslo_messaging_rabbit/rabbit_stream_fanout': value => true;
    'oslo_messaging_rabbit/use_queue_manager': value => true;
  }

}
