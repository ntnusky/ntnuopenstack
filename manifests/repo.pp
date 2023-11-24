# This class sets up the openstack repositories.
class ntnuopenstack::repo (
  Optional[String]  $release_override = undef,
){
  if($release_override) {
    $release = $release_override
  } else {
    include ::openstack_extras::repo::debian::params
    $release = $::openstack_extras::repo::debian::params::release
  }

  if ($::osfamily == 'Debian' and $::operatingsystem == 'Ubuntu') {
    $distro = $facts['os']['release']['major']
    if ($distro == '22.04' and $release == 'yoga') {
      notice('Yoga is default in Jammy. Do not use UCA')
    } else {
      class { '::openstack_extras::repo::debian::ubuntu':
        package_require => true,
        release         => $release
      }
    }
  } elsif ($::osfamily == 'RedHat') {
    include ::profile::repo::powertools
    class { '::openstack_extras::repo::redhat::redhat':
      package_require => true,
      release         => $release
      stream          => true,
    }
  } else {
    fail("Operating system family ${::osfamily} is not supported.")
  }
}
