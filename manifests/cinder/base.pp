# Configures the base cinder config
class ntnuopenstack::cinder::base {
  # Determine where the database resides 
  $mysql_pass = lookup('ntnuopenstack::cinder::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::cinder::mysql::ip', Stdlib::IP::Address)
  $database_connection = "mysql://cinder:${mysql_pass}@${mysql_ip}/cinder"

  # Credentials for the messagequeue
  $transport_url = lookup('ntnuopenstack::transport::url', String)
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  # Get the internal url to the glance API:
  $glance_internal = lookup('ntnuopenstack::glance::endpoint::internal',
                              Stdlib::Httpurl)

  if ($rabbitservers) {
    $ha_transport_conf = {
      rabbit_ha_queues    => true,
      amqp_durable_queues => true,
    }
  } else {
    $ha_transport_conf = {}
  }

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::cinder::sudo

  class { '::cinder':
    database_connection   => $database_connection,
    default_transport_url => $transport_url,
    *                     => $ha_transport_conf,
  }

  class { '::cinder::glance':
    glance_api_servers => "${glance_internal}:9292",
  }
}
