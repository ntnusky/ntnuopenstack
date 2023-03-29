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

  $vpnaas = lookup('ntnuopenstack::neutron::vpnaas::enabled', {
    'default_value' => false,
    'value_type'    => Boolean,
  })

  # We would like to have the heat dashboard
  include ::horizon::dashboards::heat

  # If the octavia keystone-password is in hiera, we assume octavia to be
  # present, and is thus installing the octavia dashboard:
  if($octavia) {
    include ::horizon::dashboards::octavia
  }

  # If the magnum keystone-password is in hiera, we assume magnum to be
  # present, and is thus installing the magnum dashboard

  # For Ubuntu, the packaging people decided to NOT follow the naming scheme
  # for Horizon Dashboards in Ubuntu, so we have to insall it "manually".
  # Magnum dashboard on Ubuntu is only available in 22.04 and newer
  if($magnum and $facts['os']['name'] == 'CentOS') {
    horizon::dashboard { 'magnum': }
  } elsif ($magnum and $facts['os']['name'] == 'Ubuntu' and 
      versioncmp($facts['os']['release']['major'], '22.04') >= 0) {
    ensure_packages('python3-magnum-ui', {
      'ensure' => 'present',
      'tag'    => ['horizon-package']
    })
  }

  # The vpnaas dashboard only exists in the Ubuntu repos...
  if($vpnaas and $facts['os']['name'] == 'Ubuntu') {
    horizon::dashboard { 'neutron-vpnaas' : }
  }
}
