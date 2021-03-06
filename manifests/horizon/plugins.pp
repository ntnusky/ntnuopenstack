# Installs extra dashboards for horizon
class ntnuopenstack::horizon::plugins {
  # Try to retrieve octavias keystone-password from hiera.
  $octavia = lookup('ntnuopenstack::octavia::keystone::password', {
    'default_value' => false,
    'value_type'    => Variant[Boolean, String],
  })
  # Try to retrieve magnums keystone-password from hiera.
  $magnum = lookup('ntnuopenstack::magnum::keystone::password', {
    'default_value' => false,
    'value_type'    => Variant[Boolean, String],
  })

  # We would like to have the heat dashboard
  horizon::dashboard { 'heat': }

  # The FWaaS is no longer maintained and will be removed in the W release
  if ($::osfamily == 'Debian') {
    horizon::dashboard { 'neutron-fwaas':
      ensure => 'absent'
    }
  }

  # The old neutron-lbaas dashboard should be removed
  horizon::dashboard { 'neutron-lbaas':
    ensure => 'absent',
  }

  # If the octavia keystone-password is in hiera, we assume octavia to be
  # present, and is thus installing the octavia dashboard:
  if($octavia) {
    horizon::dashboard { 'octavia': }
  }

  # If the magnum keystone-password is in hiera, we assume magnum to be
  # present, and is thus installing the magnum dashboard
  # (only available for RHEL/CentOS)
  if($magnum and $::osfamily == 'RedHat') {
    horizon::dashboard { 'magnum': }
  }
}
