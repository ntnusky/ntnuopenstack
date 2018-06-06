# Installs and configures the keystone identity API.
class ntnuopenstack::keystone {
  $confhaproxy = hiera('profile::openstack::haproxy::configure::backend', true)
  $keystoneip = hiera('profile::api::keystone::admin::ip', false)

  require ::profile::baseconfig::firewall
  require ::ntnuopenstack::keystone::base
  contain ::ntnuopenstack::keystone::endpoint
  contain ::ntnuopenstack::keystone::firewall::server
  contain ::ntnuopenstack::keystone::ldap
  require ::ntnuopenstack::repo

  # If this server should be placed behind haproxy, export a haproxy
  # configuration snippet.
  if($confhaproxy) {
    contain ::ntnuopenstack::keystone::haproxy::backend::server
  }

  # Only configure keepalived if we actually have a shared IP for keystone. We
  # use this in the old controller-infrastructure. New infrastructures should be
  # based on haproxy instead.
  if($keystoneip) {
    contain ::ntnuopenstack::keystone::keepalived
  }
}
