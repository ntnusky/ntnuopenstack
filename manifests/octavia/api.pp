# Installs the octavia API.
class ntnuopenstack::octavia::api {
  $api_port = lookup('ntnuopenstack::octavia::api::port', Stdlib::Port)
  $dbsync = lookup('ntnuopenstack::octavia::db::sync', Boolean, 'first', false)

  include ::ntnuopenstack::octavia::base
  include ::ntnuopenstack::octavia::firewall::api
  include ::ntnuopenstack::octavia::haproxy::backend
  require ::ntnuopenstack::repo

  class { '::octavia::api':
    port           => $api_port,
    sync_db        => $dbsync,
    api_v1_enabled => false,
  }
}
