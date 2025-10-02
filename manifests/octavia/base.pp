# Performs basic octavia configuration.
class ntnuopenstack::octavia::base {
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Array[String], Boolean],
    'default_value' => false,
  })
  $region = lookup('ntnuopenstack::region', String)

  if ($rabbitservers) {
    $ha_transport_conf = {
      rabbit_quorum_queue           => true,
      rabbit_transient_quorum_queue => true,
    }
  } else {
    $ha_transport_conf = {}
  }

  $transport_url = lookup('ntnuopenstack::transport::url')

  include ::ntnuopenstack::octavia::auth
  require ::ntnuopenstack::octavia::dbconnection
  require ::ntnuopenstack::repo

  class { '::octavia':
    default_transport_url => $transport_url,
    *                     => $ha_transport_conf,
  }

  # TODO: Monitor when this becomes a parameter in ::octavia
  octavia_config {
    'oslo_messaging_rabbit/rabbit_stream_fanout': value => true;
    'oslo_messaging_rabbit/use_queue_manager': value => true;
  }

  class { '::octavia::cinder':
    region_name => $region,
  }
  class { '::octavia::glance':
    region_name => $region,
  }
  class { '::octavia::nova':
    anti_affinity_policy => 'anti-affinity',
    enable_anti_affinity => true,
    region_name          => $region,
  }
}
