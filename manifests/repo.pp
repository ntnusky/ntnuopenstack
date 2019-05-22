# This class sets up the openstack repositories.
class ntnuopenstack::repo {
  if ($::osfamily == 'Debian') {
    if ($::operatingsystem == 'Ubuntu') {
      $distro = $facts['os']['release']['major']
      if ($distro == '18.04' and $::openstack_extras::repo::debian::params::release == 'queens') {
        notify('Queens is default in Bionic. Do not use UCA')
      } else {
        class { '::openstack_extras::repo::debian::ubuntu':
          package_require => true,
        }
      }
    } else {
      fail("Operating system family ${::osfamily} is not supported.")
    }
  }
}
