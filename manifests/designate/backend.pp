# Designate interop with DNS Backend
class ntnuopenstack::designate::backend {
  $ns_servers = lookup('ntnuopenstack::designate::ns_servers', Array[Stdlib::IP::Address]);
  $api_servers = lookup('ntnuopenstack::designate::api_servers', Array[Stdlib::IP::Address]);

  class {'::designate::backend::bind9':
    ns_records       => lookup('ntnuopenstack::designate::ns_records', Hash[Integer, String]),

    rndc_config_file => '/etc/rndc.conf',
    rndc_key_file    => '/etc/rndc.key',

    mdns_hosts       => $api_servers,
    bind9_hosts      => $ns_servers,
    nameservers      => $ns_servers,
    configure_bind   => false,
  }

  $rndc_algorithm = 'hmac-md5';
  $rndc_name = 'rndc-key';
  $rndc_secret = lookup('ntnuopenstack::designate::rndc_key', String);

  file { '/etc/rndc.conf':
    ensure  => file,
    owner   => 'designate',
    group   => 'designate',
    mode    => '0644',
    content => template('ntnuopenstack/designate/rndc-conf.erb'),
  }

  file { '/etc/rndc.key':
    ensure  => file,
    owner   => 'designate',
    group   => 'designate',
    mode    => '0640',
    content => template('ntnuopenstack/designate/rndc-key.erb'),
  }
}
