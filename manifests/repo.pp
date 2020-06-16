# This class sets up the openstack repositories.
class ntnuopenstack::repo {
  include ::openstack_extras::repo::debian::params

  if ($::osfamily == 'Debian' and $::operatingsystem == 'Ubuntu') {
    $distro = $facts['os']['release']['major']
    if ($distro == '18.04' and $::openstack_extras::repo::debian::params::release == 'queens') {
      notice('Queens is default in Bionic. Do not use UCA')
    } else {
      class { '::openstack_extras::repo::debian::ubuntu':
        package_require => true,
      }
    }
  } elsif ($::osfamily == 'RedHat') {
    class { '::openstack_extras::repo::redhat::redhat':
      package_require => true,
    }
  } else {
    fail("Operating system family ${::osfamily} is not supported.")
  }
}
