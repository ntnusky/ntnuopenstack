# Install magnum with pip3
# And hack together all binaries and services
# They are stolen from the deb-packages
class ntnuopenstack::magnum::install {
  package { 'magnum':
    ensure          => '8.2.0',
    provider        => 'pip3',
    install_options => ['-t' , '/usr/lib/python3/dist-packages'],
    tag             => ['openstack', 'magnum-package'],
  }

  file { '/etc/magnum':
    ensure  => 'directory',
    require => Package['magnum'],
  }

  file { '/etc/init.d/magnum-conductor':
    ensure => 'file',
    source => 'puppet:///modules/ntnuopenstack/openstack/magnum/services/magnum-conductor',
  }

  file { '/usr/bin':
    ensure  => 'directory',
    recurse => remote,
    source  => 'puppet:///modules/ntnuopenstack/openstack/magnum/bin',
  }

  systemd::unit_file { 'magnum-conductor.service':
    source => 'puppet:///modules/ntnuopenstack/openstack/magnum/services/magnum-conductor.service',
  }
}
