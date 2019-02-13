# Performs basic nova configuration.
class ntnuopenstack::nova::base {
  # Retrieve memcache configuration
  $memcache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[Stdlib::IP::Address],
    'default_value' => [],
  })
  $memcache = $memcache_servers.map | $server | {
    "${server}:11211"
  }

  # Retrieve mysql session
  $mysql_password = lookup('ntnuopenstack::nova::mysql::password')
  $mysql_ip = lookup('profile::haproxy::management::ipv4', {
      'value_type' => Stdlib::IP::Address,
  })
  $db_con = "mysql://nova:${mysql_password}@${mysql_ip}/nova"
  $api_db_con = "mysql://nova_api:${mysql_password}@${mysql_ip}/nova_api"

  # Nova placement configuration
  $region = lookup('ntnuopenstack::region')
  $placement_password = lookup('ntnuopenstack::nova::placement::keystone::password')
  $keystone_admin = lookup('ntnuopenstack::endpoint::admin') 
  $internal_endpoint = lookup('ntnuopenstack::endpoint::internal')

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

  require ::ntnuopenstack::repo
  include ::ntnuopenstack::nova::sudo

  class { '::nova':
    database_connection     => $db_con,
    default_transport_url   => $transport_url,
    api_database_connection => $api_db_con,
    image_service           => 'nova.image.glance.GlanceImageService',
    glance_api_servers      => "${internal_endpoint}:9292",
    *                       => $ha_transport_conf,
  }

  class { '::nova::placement':
    password       => $placement_password,
    auth_url       => "${keystone_admin}:35357/v3",
    os_region_name => $region,
  }

  class { '::nova::cache' :
    enabled          => true,
    backend          => 'oslo_cache.memcache_pool',
    memcache_servers => $memcache,
  }
}
