# Configures the basic requirements for designate and the designate-services
class ntnuopenstack::designate::services {
  include ::apache::mod::status
  require ::ntnuopenstack::designate::dbconnection
  include ::ntnuopenstack::designate::firewall::api

  # Common / base configuration
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Array[String], Boolean],
    'default_value' => false,
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

  class { '::designate':
    default_transport_url => $transport_url,
    *                     => $ha_transport_conf,
  }

  # TODO: Monitor when this becomes a parameter in ::designate
  designate_config {
    'oslo_messaging_rabbit/rabbit_stream_fanout': value => true;
    'oslo_messaging_rabbit/use_queue_manager': value => true;
  }

  # Coordination
  $zookeeper_servers = lookup('profile::zookeeper::servers', {
    'value_type'    => Hash[String, Stdlib::IP::Address::Nosubnet],
  })
  $zookeeper_urls = values($zookeeper_servers).map | $server | {
    "${server}:2181"
  }
  class { '::designate::coordination':
    backend_url => "'zookeeper://${join($zookeeper_urls, ',')}'",
  }
  # Until we update to >= https://review.opendev.org/c/openstack/puppet-oslo/+/917759
  ensure_packages('python3-kazoo', {
    'ensure' => 'present'
  })

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
    port              => Integer($api_port),
  }

  # designate-central
  class { 'designate::central':
    managed_resource_email     => lookup('ntnuopenstack::designate::hostmaster_email', Stdlib::Email),
    # Id of the "services" project that should own reverse zones
    managed_resource_tenant_id => lookup('ntnuopenstack::designate::project_id', String),
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
  }

  # designate-producer
  class { 'designate::producer':
  }

  # designate-worker
  class { 'designate::worker':
  }
}
