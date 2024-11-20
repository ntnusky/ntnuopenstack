# Configures a Designate API server, running most designate components
class ntnuopenstack::designate::api {
  require ::ntnuopenstack::repo

  contain ::ntnuopenstack::designate::haproxy::backend
  include ::ntnuopenstack::designate::sudo
  require ::ntnuopenstack::designate::auth
  require ::ntnuopenstack::designate::backend
  require ::ntnuopenstack::designate::services

}
