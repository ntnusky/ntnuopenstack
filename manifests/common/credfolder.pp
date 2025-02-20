# Creates the folders needed to store openstack-creds for puppet types.
class ntnuopenstack::common::credfolder {
  file { '/etc/openstack':
    ensure => directory,
  }

  file { '/etc/openstack/puppet':
    ensure  => directory,
    require => File['/etc/openstack'],
  }
}
