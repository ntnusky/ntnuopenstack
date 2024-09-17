# Installs and configures the keystone identity API.
class ntnuopenstack::keystone {
  $confhaproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'default_value' => true,
    'value_type'    => Boolean,
  })
  $installmunin = lookup('profile::munin::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  require ::ntnuopenstack::keystone::base
  contain ::ntnuopenstack::keystone::endpoint
  contain ::ntnuopenstack::keystone::firewall::server
  include ::ntnuopenstack::keystone::logging
  contain ::ntnuopenstack::keystone::ldap
  require ::ntnuopenstack::repo

  if($installmunin) {
    include ::profile::monitoring::munin::plugin::openstack::keystone
  }

  # If this server should be placed behind haproxy, export a haproxy
  # configuration snippet.
  if($confhaproxy) {
    contain ::ntnuopenstack::keystone::haproxy::backend
  }
}
