# Performs basic nova configuration.
class ntnuopenstack::nova::base {
  # Determine correct mysql IP
  $mysql_password = hiera('ntnuopenstack::nova::mysql::password')
  $mysql_old = hiera('profile::mysql::ip', undef)
  $mysql_new = hiera('profile::haproxy::management::ipv4', undef)
  $mysql_ip = pick($mysql_new, $mysql_old)

  # Mysql connectionstrings
  $db_con = "mysql://nova:${mysql_password}@${mysql_ip}/nova"
  $api_db_con = "mysql://nova_api:${mysql_password}@${mysql_ip}/nova_api"

  # Nova placement configuration
  $region = hiera('ntnuopenstack::region')
  $placement_password = hiera('ntnuopenstack::nova::placement::keysone::password')
  $admin_endpoint = hiera('ntnuopenstack::endpoint::admin', undef)
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip', '127.0.0.1')
  $keystone_admin = pick($admin_endpoint, "http://${keystone_admin_ip}")

  # RabbitMQ connection-information
  $transport_url = hiera('ntnuopenstack::transport::url')

  $internal_endpoint = hiera('ntnuopenstack::endpoint::internal', false)
  if($internal_endpoint) {
    $glance_internal = "${internal_endpoint}:9292"
  } else {
    $controller_management_addresses = hiera('controller::management::addresses')
    $oldapi = join([join($controller_management_addresses, ':9292,'),''], ':9292')
    $glance_internal = $oldapi
  }

  require ::ntnuopenstack::repo
  include ::ntnuopenstack::nova::sudo

  class { '::nova':
    database_connection     => $db_con,
    default_transport_url   => $transport_url,
    api_database_connection => $api_db_con,
    image_service           => 'nova.image.glance.GlanceImageService',
    glance_api_servers      => $glance_internal,
  }

  class { '::nova::placement':
    password       => $placement_password,
    auth_url       => "${keystone_admin}:35357/v3",
    os_region_name => $region,
  }
}
