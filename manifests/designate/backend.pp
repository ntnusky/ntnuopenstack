# Designate interop with DNS Backend
class ntnuopenstack::designate::backend {
  class {'::designate::backend::bind9':
    ns_records       => lookup('ntnuopenstack::designate::ns_records', Hash[Integer, String]),

    rndc_config_file => '/etc/rndc.conf',
    rndc_key_file    => '/etc/rndc.key',

    bind9_hosts      => lookup('ntnuopenstack::designate::ns_servers', Array[String]),
    nameservers      => lookup('ntnuopenstack::designate::ns_servers', Array[String]),
    configure_bind   => false,
  }

  file { '/etc/rndc.conf':
    ensure => present,
    owner  => 'root',
    group  => 'designate',
    mode   => '0644',
    source =>
      'puppet:///modules/ntnuopenstack/designate/rndc.conf',
    before => Anchor['designate::service::begin'],
  }

  $rndc_algorithm = 'hmac-md5';
  $rndc_name = 'rndc-key';
  $rndc_secret = lookup('ntnuopenstack::designate::rndc_key', String);

  file { '/etc/rndc.key':
    ensure  => file,
    owner   => 'designate',
    group   => 'designate',
    mode    => '0640',
    content => template('ntnuopenstack/designate/rndc-key.erb'),
  }
}
