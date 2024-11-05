# Designate DNS Backend (bind9)
class ntnuopenstack::designate::backend {
  class {'::designate::backend::bind9':
    ns_records       => lookup('ntnuopenstack::designate::ns_records'),

    rndc_config_file => '/etc/rndc.conf',
    rndc_key_file    => '/etc/bind/rndc.key'
  }

  file { '/etc/rndc.conf':
    ensure => present,
    owner  => 'root',
    group  => 'bind',
    mode   => '0644',
    source =>
      'puppet:///modules/ntnuopenstack/designate/rndc.conf',
    before => Anchor['designate::service::begin'],
  }
}
