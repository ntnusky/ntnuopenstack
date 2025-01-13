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
  $nova_fixed_zone = lookup('ntnuopenstack::designate::nova_fixed::zone_id', String)
  $neutron_floatingip_zone = lookup('ntnuopenstack::designate::neutron_floatingip::zone_id', String)
  class { 'designate::sink':
    workers                       => 2,
    enabled_notification_handlers => 'nova_fixed, neutron_floatingip',
  }
  designate_config {
    'handler:nova_fixed/zone_id':             value => $nova_fixed_zone;
    'handler:nova_fixed/control_exchange':    value => 'nova';
    'handler:nova_fixed/notification_topics': value => 'notifications_designate';
    # 'handler:nova_fixed/formatv4':            value => '%(octet0)s-%(octet1)s-%(octet2)s-%(octet3)s.%(zone)s';
    'handler:nova_fixed/formatv4':            value => '%(hostname)s.%(project)s.%(zone)s';
    'handler:nova_fixed/formatv6':            value => '%(hostname)s.%(project)s.%(zone)s';
  }
  designate_config {
    'handler:neutron_floatingip/zone_id':             value => $neutron_floatingip_zone;
    'handler:neutron_floatingip/control_exchange':    value => 'neutron';
    'handler:neutron_floatingip/notification_topics': value => 'notifications_designate';
    'handler:neutron_floatingip/formatv4':            value => '%(hostname)s.%(project)s.%(zone)s';
  }

  # designate-worker
  class { 'designate::worker':
    workers => 2,
  }
}
