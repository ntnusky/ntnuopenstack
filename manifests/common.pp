# Common configuration for all openstack resources
class ntnuopenstack::common {

  require ::ntnuopenstack::repo

  case $::osfamily {
    'RedHat': {
      package { 'openstack-selinux':
        ensure  => 'present',
      }
    }
    default: {}
  }
}
