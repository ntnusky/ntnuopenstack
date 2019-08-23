# Ensures that glance-registry is disabled and removed. It is deprecated as of
# Queens, and will be removed at Stein.  
class ntnuopenstack::glance::registry {
  class { '::glance::registry':
    package_ensure => 'absent',
    enabled        => false,
  }
}
