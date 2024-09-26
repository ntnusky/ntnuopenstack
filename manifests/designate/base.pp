# Performs basic designate configuration.
class ntnuopenstack::designate::base {
  # Keystone authentication setup
  $keystone_password = lookup('ntnuopenstack::designate::keystone::password', String, 'first', undef)
  class {'designate::keystone::auth':
    password => $keystone_password,
  }

  # RabbitMQ connection-information
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

  require ::ntnuopenstack::designate::dbconnection

  class { '::designate':
    default_transport_url => $transport_url,
    *                     => $ha_transport_conf,
  }

  include designate::central
  include designate::client
}
