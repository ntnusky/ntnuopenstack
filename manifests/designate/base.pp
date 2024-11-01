# Performs basic designate configuration.
class ntnuopenstack::designate::base {
  require ::ntnuopenstack::designate::dbconnection
  include ::ntnuopenstack::designate::firewall::api
  include ::ntnuopenstack::designate::firewall::dns

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

  class { '::designate':
    default_transport_url => $transport_url,
    *                     => $ha_transport_conf,
  }

  include ::ntnuopenstack::designate::policy
  $barbican =   class {'::designate::policy':
    policies => $designatePolicies,
  }

  class { 'designate::central':
    managed_resource_email     => 'hostmaster@ntnu.no',
    managed_resource_tenant_id => lookup('ntnuopenstack::admin_project_id', {
      'value_type'    => String,
      'default_value' => '00000000-0000-0000-0000-000000000000',
    }),
  }

  include designate::client

  class { 'designate::mdns':
    listen  =>  "0.0.0.0:5354",
    workers => 2,
  }

  class { 'designate::producer':
    workers => 2,
  }

  class { 'designate::worker':
    workers => 2,
  }
}
