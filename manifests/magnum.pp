# Installs and configures magnum api and magnum conductor
class ntnuopenstack::magnum {
  require ::ntnuopenstack::repo
  require ::ntnuopenstack::common
  include ::ntnuopenstack::magnum::api
  include ::ntnuopenstack::magnum::params
  include ::profile::services::apache::logging

  $package_ensure = $::ntnuopenstack::magnum::params::package_ensure

  class { '::magnum::conductor':
    package_ensure => $package_ensure,
  }
}
