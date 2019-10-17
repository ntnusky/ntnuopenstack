# Basic nova configuration for compute nodes.
class ntnuopenstack::nova::base::compute {
  # Determine correct mysql settings
  $mysql_password = lookup('ntnuopenstack::nova::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::nova::mysql::ip', Stdlib::IP::Address)
  $database_connection = "mysql://nova:${mysql_password}@${mysql_ip}/nova"

  $internal_endpoint = lookup('ntnuopenstack::endpoint::internal')

  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Array[String], Boolean],
    'default_value' => false,
  })
  $transport_url = lookup('ntnuopenstack::transport::url', String)

  $placement_password = lookup('ntnuopenstack::nova::placement::keystone::password')
  $region = lookup('ntnuopenstack::region')

  require ::ntnuopenstack::repo
  include ::ntnuopenstack::nova::sudo
  include ::ntnuopenstack::nova::firewall::compute

  if ($rabbitservers) {
    $ha_transport_conf = {
      rabbit_ha_queues    => true,
      amqp_durable_queues => true,
    }
  } else {
    $ha_transport_conf = {}
  }

  class { '::nova':
    database_connection           => $database_connection,
    default_transport_url         => $transport_url,
    glance_api_servers            => "${internal_endpoint}:9292",
    block_device_allocate_retries => 120,
    *                             => $ha_transport_conf,
  }

  class { '::nova::placement':
    password       => $placement_password,
    auth_url       => "${internal_endpoint}:5000/v3",
    os_region_name => $region,
  }
}
