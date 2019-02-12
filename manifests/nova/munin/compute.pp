# Installs munin plugins, if munin is enabled.
class ntnuopenstack::nova::munin::compute {
  $installmunin = lookup('profile::munin::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  if($installmunin) {
    include ::profile::monitoring::munin::plugin::compute
  }
}

