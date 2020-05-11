# Baseconfig for all magnum services
class ntnuopenstack::magnum::base {
  $domain_password = lookup('ntnuopenstack::magnum::domain_password', String)
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

  class { '::magnum':
    default_transport_url => $transport_url,
    *                     => $ha_transport_conf,
  }

  class { '::magnum::keystone::domain':
    cluster_user_trust => true,
    manage_domain      => false,
    manage_user        => false,
    manage_role        => false,
    domain_password    => $domain_password,
  }

  magnum_config {
    'cinder/default_docker_volume_type': value => 'Normal';
  }
}
