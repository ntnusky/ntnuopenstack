# Installs the Magnum API
class ntnuopenstack::magnum::api {
  $rabbitservers = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Array[String], Boolean],
    'default_value' => false,
  })
  $sync_db = lookup('ntnuopenstack::magnum::db::sync', Boolean)
  $transport_url = lookup('ntnuopenstack::transport::url')

  require ::ntnuopenstack::magnum::base
  include ::ntnuopenstack::magnum::clients
  include ::ntnuopenstack::magnum::firewall::api
  include ::ntnuopenstack::magnum::haproxy::backend

  class { '::magnum::api':
    enabled        => false,
    package_ensure => 'absent',
    service_name   => 'httpd',
    sync_db        => $sync_db,
    enabled_ssl    => false,
  }

  class { '::magnum::wsgi::apache':
    ssl               => false,
    access_log_format => 'forwarded',
  }
}
