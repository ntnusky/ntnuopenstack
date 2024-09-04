# Installs the designate API.
class ntnuopenstack::designate::api {
  $keystone_password = lookup('ntnuopenstack::designate::keystone::password', String, 'first', undef)

  class { '::designate::api':
    auth_strategy     => "keystone",
    keystone_password => $keystone_password,
  }
}
