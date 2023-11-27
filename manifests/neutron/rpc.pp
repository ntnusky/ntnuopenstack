# Installs the service-files for the neutron-rpc-service, as they apparently is
# not packaged for Ubuntu
class ntnuopenstack::neutron::rpc {
  include ::neutron::deps

  file { '/etc/init.d/neutron-rpc-server':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/ntnuopenstack/initd/neutron-rpc-server',
    before => Anchor['neutron::install::end'],
    notify => Exec['systemd-reload'],
  }

  file { '/lib/systemd/system/neutron-rpc-server.service':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source =>
      'puppet:///modules/ntnuopenstack/systemd/neutron-rpc-server.service',
    before => Anchor['neutron::install::end'],
    notify => Exec['systemd-reload'],
  }
}
