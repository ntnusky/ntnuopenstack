# Performs basic octavia configuration.
class ntnuopenstack::octavia::base {
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Array[String], Boolean],
    'default_value' => false,
  })
  $region = lookup('ntnuopenstack::region', String)

  if ($rabbitservers) {
    $ha_transport_conf = {
      rabbit_ha_queues    => true,
      amqp_durable_queues => true,
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

  class { '::octavia::certificates':
    region_name => $region, 
  }
  class { '::octavia::cinder':
    region_name => $region, 
  }
  class { '::octavia::glance':
    region_name => $region, 
  }
  class { '::octavia::neutron':
    region_name => $region, 
  }
  class { '::octavia::nova':
    anti_affinity_policy => 'anti-affinity',
    enable_anti_affinity => true,
    region_name          => $region, 
  }
}
