# Installs munin plugins for the nova API, if munin is enabled.
class ntnuopenstack::nova::munin::api {
  $installmunin = lookup('profile::munin::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  if($installmunin) {
    include ::profile::monitoring::munin::plugin::nova
  }
}
