# Installs the x509-certificate used for the administratrive APIs
class ntnuopenstack::cert::adminapi {
  $certificate = lookup('ntnuopenstack::endpoint::admin::cert', {
    'value_type'    => String,
  })
  $certfile = lookup('ntnuopenstack::endpoint::admin::cert::path', {
    'default_value' => '/etc/ssl/private/haproxy.managementapi.pem',
    'value_type'    => Stdlib::Unixpath,
  })

  if ($certificate) {
    file { $certfile:
      ensure  => 'present',
      content => $certificate,
      mode    => '0600',
      notify  => Service['haproxy'],
    }
  }
}
