# In focal we need at least version '2.13.3-7ubuntu5.2' of apparmor to run
# Yoga. This package is as of 09.march 2023 only available in the
# proposed-repositores, and this class installs that version of apparmor from
# the proposed repositories.
class ntnuopenstack::nova::compute::apparmor {
  require ::project::apt::proposed

  package { 'apparmor':
    ensure => '>= 2.13.3-7ubuntu5.2',
  }
}
