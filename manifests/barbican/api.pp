# Installs the Barbican API
class ntnuopenstack::barbican::api {
  $confhaproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'value_type'    => Boolean,
    'default_value' => true,
  })
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Array[String], Boolean],
    'default_value' => false,
  })
  $sync_db = lookup('ntnuopenstack::barbican::db::sync', Boolean)
  $transport_url = lookup('ntnuopenstack::transport::url')

  if ($rabbitservers) {
    $ha_transport_conf = {
      rabbit_ha_queues    => true,
      amqp_durable_queues => true,
    }
  } else {
    $ha_transport_conf = {}
  }

  include ::apache::mod::status
  require ::ntnuopenstack::barbican::auth
  require ::ntnuopenstack::barbican::dbconnection
  include ::ntnuopenstack::barbican::firewall::api
  include ::ntnuopenstack::barbican::haproxy::backend

  class { '::barbican::api':
    enabled                      => false,
    enable_proxy_headers_parsing => $confhaproxy,
    default_transport_url        => $transport_url,
    host_href                    => '',
    service_name                 => 'httpd',
    sync_db                      => $sync_db,
    *                            => $ha_transport_conf,
  }

  class { '::barbican::wsgi::apache':
    ssl               => false,
    access_log_format => 'forwarded',
  }
}
