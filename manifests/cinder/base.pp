# Configures the base cinder config
class ntnuopenstack::cinder::base {
  # Credentials for the messagequeue
  $transport_url = lookup('ntnuopenstack::transport::url', String)
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  # Get the internal url to the glance API:
  $glance_internal = lookup('ntnuopenstack::glance::endpoint::internal',
                              Stdlib::Httpurl)
  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $password = lookup('ntnuopenstack::cinder::keystone::password')
  $region_name = lookup('ntnuopenstack::region')

  if ($rabbitservers) {
    $ha_transport_conf = {
      rabbit_ha_queues    => true,
      amqp_durable_queues => true,
    }
  } else {
    $ha_transport_conf = {}
  }

  include ::ntnuopenstack::cinder::dbconnection
  require ::ntnuopenstack::cinder::sudo
  require ::ntnuopenstack::keystone::bootstrap
  require ::ntnuopenstack::repo

  class { '::cinder':
    default_transport_url => $transport_url,
    *                     => $ha_transport_conf,
  }
  
  class { '::cinder::glance':
    glance_api_servers => "${glance_internal}:9292",
  }

  class { '::cinder::keystone::service_user':
    auth_url    => $auth_url,
    password    => $password,
    region_name => $region_name,
  }

  class { '::cinder::nova':
    auth_url     => $auth_url,
    interface    => 'internal',
    password     => $password,
    region_name  => $region_name,
    system_scope => 'all',
  }
}
