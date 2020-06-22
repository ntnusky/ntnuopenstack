# Common parameters
class ntnuopenstack::magnum::params {
  case $::osfamily {
    'Debian': {
      $package_ensure = 'absent'
    }
    'RedHat': {
      $package_ensure = 'present'
    }
    default: {}
  }
}
