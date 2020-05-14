# Install magnum with pip3
class ntnuopenstack::magnum::install {
  package { 'magnum':
    ensure   => '8.2.0',
    provider => 'pip3',
    tag      => ['openstack', 'magnum-package'],
  }

  file { '/etc/magnum':
    ensure => 'directory',
    after  => Package['magnum'],
  }
}
