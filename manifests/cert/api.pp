# Installs the x509-certificate used for the public APIs
class ntnuopenstack::cert::api {
  $certificate = lookup('ntnuopenstack::endpoint::public::cert', {
    'value_type'    => String,
  })
  $certfile = lookup('ntnuopenstack::endpoint::public::cert::path', {
    'default_value' => '/etc/ssl/private/haproxy.servicesapi.pem',
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
