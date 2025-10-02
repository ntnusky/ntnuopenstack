# Baseconfig for all magnum services
class ntnuopenstack::magnum::base {
  $domain_password = lookup('ntnuopenstack::magnum::domain_password', String)
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Array[String], Boolean],
    'default_value' => false,
  })
  $default_volume_type = lookup('ntnuopenstack::cinder::type::default', {
    'value_type'    => String,
    'default_value' => 'Normal',
  })

  if ($rabbitservers) {
    $ha_transport_conf = {
      rabbit_quorum_queue           => true,
      rabbit_transient_quorum_queue => true,
    }
  } else {
    $ha_transport_conf = {}
  }

  $transport_url = lookup('ntnuopenstack::transport::url')
  $region = lookup('ntnuopenstack::region', String)

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::magnum::auth
  require ::ntnuopenstack::magnum::dbconnection
  include ::ntnuopenstack::magnum::logrotate

  class { '::magnum':
    default_transport_url => $transport_url,
    *                     => $ha_transport_conf,
  }

  class { '::magnum::keystone::domain':
    cluster_user_trust   => true,
    manage_domain        => false,
    manage_user          => false,
    manage_role          => false,
    domain_password      => $domain_password,
    keystone_region_name => $region,
  }

  class { '::magnum::cinder':
    default_docker_volume_type => $default_volume_type,
  }

  # TODO: Monitor when this becomes a parameter in ::magnum
  magnum_config {
    'oslo_messaging_rabbit/rabbit_stream_fanout': value => true;
    'oslo_messaging_rabbit/use_queue_manager': value => true;
  }
}
