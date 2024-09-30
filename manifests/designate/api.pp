# Installs the designate API.
class ntnuopenstack::designate::api {
  require ::ntnuopenstack::designate::base
  require ::ntnuopenstack::designate::auth

  class { '::designate::api':
    auth_strategy     => 'keystone',
  }
}
