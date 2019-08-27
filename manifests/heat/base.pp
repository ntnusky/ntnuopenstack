# Perfomes basic heat configuration
class ntnuopenstack::heat::base {
  # Openstack settings
  $region = lookup('ntnuopenstack::region', String)
  $keystone_admin  = lookup('ntnuopenstack::keystone::endpoint::admin', Stdlib::Httpurl)
  $keystone_internal = lookup('ntnuopenstack::keystone::endpoint::internal', Stdlib::Httpurl)
  $db_sync = lookup('ntnuopenstack::heat::db::sync', Boolean)

  # Memcached servers
  $cache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[String],
    'merge'         => 'unique',
  })
  $memcache = $cache_servers.map | $server | {
    "${server}:11211"
  }

  # Rabbitmq servers
  $transport_url = lookup('ntnuopenstack::transport::url', String)
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  # Database-connection
  $mysql_pass = lookup('ntnuopenstack::heat::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::heat::mysql::ip', Stdlib::IP::Address)
  $database_connection = "mysql+pymysql://heat:${mysql_pass}@${mysql_ip}/heat"

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
    database_connection          => $database_connection,
    default_transport_url        => $transport_url,
    region_name                  => $region,
    enable_proxy_headers_parsing => true,
    sync_db                      => $db_sync,
    *                            => $ha_transport_conf,
  }
}
