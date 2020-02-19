# Installs extra dashboards for horizon
class ntnuopenstack::horizon::plugins {
  # Try to retrieve octavias keystone-password from hiera.
  $octavia = lookup('ntnuopenstack::octavia::keystone::password', {
    'default_value' => false,
    'value_type'    => Variant[Boolean, String],
  })

  # We would like to have the heat and neutron fwaas dashboards. 
  horizon::dashboard { 'heat': }
  horizon::dashboard { 'neutron-fwaas': }

  # The old neutron-lbaas dashboard should be removed
  horizon::dashboard { 'neutron-lbaas':
    ensure => 'absent',
  }

  # If the octavia keystone-password is in hiera, we assume octavia to be
  # present, and is thus installing the octavia dashboard:
  horizon::dashboard { 'octavia': }
}
