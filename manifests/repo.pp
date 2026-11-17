# This class sets up the openstack repositories.
# NOTE: There is no longer any logic for automatically opting-out of UCA
# when we run the default OpenStack version for the current Ubuntu Release
# set 'openstack_extras::repo::debian::ubuntu::manage_uca: false' in hiera if needed
class ntnuopenstack::repo {
  if ($::facts['os']['name'] == 'Ubuntu') {
    class { '::openstack_extras::repo::debian::ubuntu':
      package_require => true,
    }
  } else {
    fail("Operating system family ${::facts['os']['name']} is not supported.")
  }
}
