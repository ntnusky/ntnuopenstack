# Perfomes basic heat configuration
class ntnuopenstack::heat::base {
  # Openstack settings
  $region = lookup('ntnuopenstack::region', String)
  $keystone_admin  = lookup('ntnuopenstack::keystone::endpoint::admin', Stdlib::Httpurl)
  $keystone_internal = lookup('ntnuopenstack::keystone::endpoint::internal', Stdlib::Httpurl)
  $db_sync = lookup('ntnuopenstack::heat::db::sync', Boolean)

  # Rabbitmq servers
  $transport_url = lookup('ntnuopenstack::transport::url', String)
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  include ::ntnuopenstack::heat::cache
  require ::ntnuopenstack::heat::dbconnection
  require ::ntnuopenstack::repo

  if ($rabbitservers) {
    $ha_transport_conf = {
      rabbit_ha_queues    => true,
      amqp_durable_queues => true,
    }
  } else {
    $ha_transport_conf = {}
  }

  class { '::heat':
    enable_stack_adopt           => true,
    enable_stack_abandon         => true,
    default_transport_url        => $transport_url,
    region_name                  => $region,
    enable_proxy_headers_parsing => true,
    sync_db                      => $db_sync,
    *                            => $ha_transport_conf,
  }

  class { '::ntnuopenstack::heat::domain':
    create_domain => false,
  }
}
