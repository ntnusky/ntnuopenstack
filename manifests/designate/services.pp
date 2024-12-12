# Configures the basic requirements for designate and the designate-services
class ntnuopenstack::designate::services {
  require ::ntnuopenstack::designate::dbconnection
  include ::ntnuopenstack::designate::firewall::api

  # Common / base configuration
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

  # Coordination
  $memcached_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[String],
    'merge'         => 'unique',
  })
  $memcache_urls = $memcached_servers.map | $server | {
    "memcached://${server}:11211"
  }
  if($coordination_url) {
    class { '::designate::coordination':
      backend_url => join($memcache_urls, ','),
    }
  }

  # designate-api
  $api_port = lookup('ntnuopenstack::designate::api::port')

  class { '::designate::api':
    auth_strategy    => 'keystone',
    enable_api_v2    => true,
    enable_api_admin => true,
    service_name     => 'httpd',
  }

  class { '::designate::wsgi::apache':
    access_log_format => 'forwarded',
    workers           => 2,
    port              => Integer($api_port),
  }

  # designate-central
  class { 'designate::central':
    managed_resource_email     => lookup('ntnuopenstack::designate::hostmaster_email', Stdlib::Email),
    # Id of the "services" project that should own reverse zones
    managed_resource_tenant_id => lookup('ntnuopenstack::designate::project_id', {
      'value_type'    => String,
      'default_value' => '00000000-0000-0000-0000-000000000000',
    }),
  }

  # designate-client
  include designate::client
  ensure_packages('bind9-utils', {
    'ensure' => 'present'
  })

  # designate-mdns
  include ::ntnuopenstack::designate::firewall::mdns
  class { 'designate::mdns':
    listen  =>  '0.0.0.0:5354',
    workers => 2,
  }

  # designate-producer
  class { 'designate::producer':
    workers => 2,
  }

  # designate-sink
  # https://bugs.launchpad.net/kolla-ansible/+bug/1919387
  # class { 'designate::sink':
  #   workers => 2,
  # }

  # designate-worker
  class { 'designate::worker':
    workers => 2,
  }
}
