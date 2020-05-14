# Install magnum with pip3
class ntnuopenstack::magnum::install {
  package { 'magnum':
    ensure          => '8.2.0',
    provider        => 'pip3',
    install_options => {
      '-t' => '/usr/lib/python3/dist-packages',
    },
    tag             => ['openstack', 'magnum-package'],
  }

  file { '/etc/magnum':
    ensure  => 'directory',
    require => Package['magnum'],
  }
}
