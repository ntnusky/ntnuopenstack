# Install magnum with pip3
# And hack together all binaries and services
# They are stolen from the deb-packages

# All of this should be reverted back to apt and puppet-magnum
# when UCA decides to include a newer version than 8.0.0 of magnum
class ntnuopenstack::magnum::install {

  require ::ntnuopenstack::common::pymemcache

  package { 'magnum':
    ensure          => '8.2.0',
    provider        => 'pip3',
    install_options => ['-t' , '/usr/lib/python3/dist-packages'],
    tag             => ['openstack', 'magnum-package'],
  }

  package { 'python-openstackclient':
    ensure   => '3.18.1',
    provider => 'pip3',
    require  => Package['magnum'],
  }

  package { 'keystoneauth1':
    ensure   => '3.13.1',
    provider => 'pip3',
    require  => Package['python-openstackclient'],
  }

  package { 'keystonemiddleware':
    ensure   => '6.0.0',
    provider => 'pip3',
    require  => Package['python-openstackclient'],
  }

  user { 'magnum':
    ensure     => 'present',
    home       => '/var/lib/magnum',
    managehome => true,
    system     => true,
  }

  file { '/etc/magnum':
    ensure  => 'directory',
    require => Package['magnum'],
  }

  file { '/var/log/magnum':
    ensure => 'directory',
    owner  => 'magnum',
    group  => 'magnum',
  }

  file { '/etc/init.d/magnum-conductor':
    ensure => 'file',
    source => 'puppet:///modules/ntnuopenstack/openstack/magnum/services/magnum-conductor',
    mode   => '0755',
  }

  file { '/usr/bin':
    ensure  => 'directory',
    recurse => remote,
    mode    => '0755',
    source  => 'puppet:///modules/ntnuopenstack/openstack/magnum/bin',
  }

  file { '/etc/magnum/api-paste.ini':
    ensure => 'file',
    source => 'puppet:///modules/ntnuopenstack/openstack/magnum/conf/api-paste.ini',
  }

  systemd::unit_file { 'magnum-conductor.service':
    source => 'puppet:///modules/ntnuopenstack/openstack/magnum/services/magnum-conductor.service',
  }
}
