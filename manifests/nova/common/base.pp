# Performs the common nova configuration.
class ntnuopenstack::nova::common::base (
  $extra_options = {},
){
  # Retrieve mysql parameters
  $mysql_password = lookup('ntnuopenstack::nova::mysql::password')
  $mysql_ip = lookup('ntnuopenstack::nova::mysql::ip', {
      'value_type' => Stdlib::IP::Address,
  })

  $db_con = "mysql+pymysql://nova:${mysql_password}@${mysql_ip}/nova"
  $api_db_con = "mysql+pymysql://nova_api:${mysql_password}@${mysql_ip}/nova_api"

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

  class { '::nova':
    database_connection   => $db_con,
    default_transport_url => $transport_url,
    *                     => $ha_transport_conf + $extra_options,
  }
}
