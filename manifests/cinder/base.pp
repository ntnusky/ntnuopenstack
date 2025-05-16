# Configures the base cinder config
class ntnuopenstack::cinder::base {
  # Credentials for the messagequeue
  $transport_url = lookup('ntnuopenstack::transport::url', String)
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  # Get the internal url to the glance API:
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })
  $region_name = lookup('ntnuopenstack::region')
  $api_internal = $services[$region_name]['url']['internal']

  $auth_url = lookup('ntnuopenstack::keystone::auth::url')

  if ($rabbitservers) {
    $ha_transport_conf = {
      rabbit_ha_queues    => true,
      amqp_durable_queues => true,
    }
  } else {
    $ha_transport_conf = {}
  }

  require ::ntnuopenstack::cinder::auth
  include ::ntnuopenstack::cinder::dbconnection
  require ::ntnuopenstack::cinder::sudo
  require ::ntnuopenstack::repo

  class { '::cinder':
    default_transport_url => $transport_url,
    *                     => $ha_transport_conf,
  }

  class { '::cinder::glance':
    glance_api_servers => "${api_internal}:9292",
  }

  class { '::cinder::nova':
    auth_type   => 'password',
    auth_url    => $auth_url,
    interface   => 'internal',
    password    =>
      $services[$region_name]['services']['nova']['keystone']['password'],
    region_name => $region_name,
    username    =>
      $services[$region_name]['services']['nova']['keystone']['username'],
  }
}
