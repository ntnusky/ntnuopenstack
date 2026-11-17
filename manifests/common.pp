# Common configuration for all openstack resources
class ntnuopenstack::common {

  require ::ntnuopenstack::repo

  case $::facts['os']['family'] {
    'RedHat': {
      package { 'openstack-selinux':
        ensure  => 'present',
      }
    }
    default: {}
  }
}
