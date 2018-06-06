# Installs munin plugins for the nova API, if munin is enabled.
class ntnuopenstack::nova::munin::api {
  $installmunin = hiera('profile::munin::install', true)

  if($installmunin) {
    include ::profile::monitoring::munin::plugin::nova
  }
}
