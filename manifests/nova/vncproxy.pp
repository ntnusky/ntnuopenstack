# Installs the nova vnc proxy
class ntnuopenstack::nova::vncproxy {
  include ::nova::deps
  include ::ntnuopenstack::nova::firewall::vncproxy
  require ::ntnuopenstack::repo

  $host = lookup('ntnuopenstack::nova::vncproxy::host')
  $port = lookup('ntnuopenstack::nova::vncproxy::port', {
    'default_value' => 6080,
    'value_type'    => Integer,
  })
  $cert = hiera('ntnuopenstack::endpoint::public::cert', {
    'default_value' => false,
  })

  $confhaproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  if($confhaproxy) {
    include ::ntnuopenstack::nova::haproxy::backend::vnc
  }

  if($cert) {
    $protocol = 'https'
  } else {
    $protocol = 'http'
  }

  class { '::nova::vncproxy::common':
    vncproxy_host     => $host,
    vncproxy_protocol => $protocol,
    vncproxy_port     => $port,
  }

  nova_config {
    'vnc/novncproxy_host': value => '0.0.0.0';
    'vnc/novncproxy_port': value => $port;
  }

  nova::generic_service { 'vncproxy':
    enabled        => true,
    manage_service => true,
    package_name   => 'nova-novncproxy',
    service_name   => 'nova-novncproxy',
    ensure_package => present,
  }
}
