# Installs and configures magnum api and magnum conductor
class ntnuopenstack::magnum {
  require ::ntnuopenstack::repo
  include ::ntnuopenstack::magnum::api
  class { '::magnum::conductor':
    package_ensure => 'absent',
  }
}
