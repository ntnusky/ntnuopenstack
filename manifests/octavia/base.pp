# Performs basic octavia configuration.
class ntnuopenstack::octavia::base {
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Array[String], Boolean],
    'default_value' => false,
  })
  $region = lookup('ntnuopenstack::region', String)

  if ($rabbitservers) {
    $ha_transport_conf = {
      rabbit_qos_prefetch_count     => 1,
      rabbit_quorum_queue           => true,
      rabbit_stream_fanout          => true,
      rabbit_transient_queues_ttl   => 0,
      rabbit_transient_quorum_queue => true,
      rabbit_use_queue_manager      => true,
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

  octavia_config {
    'oslo_messaging_rabbit/kombu_reconnect_splay': value => 2;
    'oslo_concurrency/lock_path': value => '/var/lock/octavia';
  }
}
