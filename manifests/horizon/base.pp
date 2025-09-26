# Installs and configures horizon
class ntnuopenstack::horizon::base {
  # Determine if haproxy should be configured
  $haproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  # Horizon settings
  $server_name = lookup('ntnuopenstack::horizon::server_name')
  $aliases = lookup('ntnuopenstack::horizon::server_aliases', {
    'default_value' => [],
    'value_type'    => Array[String],
  })
  $django_secret = lookup('ntnuopenstack::horizon::django_secret')
  $ldap_name = lookup('ntnuopenstack::keystone::ldap_backend::name')
  $description = lookup('ntnuopenstack::horizon::ldap::description', {
    'value_type'    => String,
    'default_value' => "${ldap_name} accounts",
  })
  $session_timeout = lookup('ntnuopenstack::horizon::session_timeout', {
    'value_type'    => Integer,
    'default_value' => 7200,
  })
  $keystone = lookup('ntnuopenstack::keystone::endpoint::public', Stdlib::Httpurl)
  $help_url = lookup('ntnuopenstack::horizon::help_url', {
    'value_type'    => Stdlib::Httpurl,
    'default_value' => 'https://docs.openstack.org',
  })
  $timezone = lookup('ntnuopenstack::horizon::timezone', {
    'value_type'    => String,
    'default_value' => 'Europe/Oslo',
  })

  # Try to retrieve memcache addresses.
  $memcache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Variant[Array[String], Boolean],
    'default_value' => false,
    'merge'         => 'unique',
  })

  $upload_mode = lookup('ntnuopenstack::horizon::upload_mode', {
    'value_type'    => Enum['direct', 'legacy', 'off'],
    'default_value' => 'legacy',
  })

  $image_formats = lookup('ntnuopenstack::glance::disk_formats', {
    'value_type'    => Hash[String, String],
    'default_value' => { 'raw' => 'Raw', 'qcow2' => 'QCOW2 - QEMU Emulator' }
  })

  $image_backend = {
    'image_formats' => $image_formats,
  }

  include ::profile::services::apache::firewall
  require ::ntnuopenstack::repo
  require ::ntnuopenstack::common
  require ::ntnuopenstack::horizon::deps

  # If this server should be placed behind haproxy, make sure to configure it.
  if($haproxy) {
    include ::ntnuopenstack::horizon::haproxy::backend
    $extra_params = {
      access_log_format => 'forwarded',
    }
    $secure_proxy_addr_header = 'HTTP_X_FORWARDED_FOR'
  } else {
    $extra_params = undef
    $secure_proxy_addr_header = undef
  }

  # Determine which cacheservers to use
  if($memcache_servers) {
    $memcache = {
      'cache_backend'         =>
          'django.core.cache.backends.memcached.PyMemcacheCache',
      'cache_server_ip'       => $memcache_servers,
      'cache_options'         =>  { 'ignore_exc' => 'True' },
      'django_session_engine' => 'django.contrib.sessions.backends.cache',
    }
  } else {
    $memcache = {}
  }

  include ::apache::mod::status

  class { '::horizon':
    allowed_hosts                  => [$::fqdn, $server_name] + $aliases,
    default_theme                  => 'default',
    enable_secure_proxy_ssl_header => $haproxy,
    help_url                       => $help_url,
    horizon_upload_mode            => $upload_mode,
    keystone_default_domain        => $ldap_name,
    keystone_multidomain_support   => true,
    keystone_url                   => "${keystone}:5000",
    keystone_domain_choices        => [
      {'name' => $ldap_name, 'display' => $description},
      {'name' => 'default',  'display' => 'Openstack accounts'},
    ],
    image_backend                  => $image_backend,
    manage_memcache_package        => false,
    instance_options               => {
      create_volume => false,
    },
    password_retrieve              => true,
    root_url                       => '/horizon',
    secure_cookies                 => $haproxy,
    secret_key                     => $django_secret,
    secure_proxy_addr_header       => $secure_proxy_addr_header,
    server_aliases                 => [$::fqdn, $server_name] + $aliases,
    servername                     => $server_name,
    session_timeout                => $session_timeout,
    timezone                       => $timezone,
    vhost_extra_params             => $extra_params,
    *                              => $memcache,
  }
}
