# Installs the service-files for the neutron-rpc-service, as they apparently is
# not packaged for Ubuntu
class ntnuopenstack::neutron::rpc {
  include ::neutron::deps
  include ::profile::systemd::reload

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
