# Installs and configures the heat engine.
class ntnuopenstack::heat::engine {
  $heat_internal = lookup('ntnuopenstack::heat::endpoint::internal',
                              Stdlib::Httpurl)
  $auth_encryption_key = lookup('ntnuopenstack::heat::auth_encryption_key')

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::heat::base

  class { '::heat::engine':
    auth_encryption_key           => $auth_encryption_key,
    heat_metadata_server_url      => "${heat_internal}:8000",
    heat_waitcondition_server_url => "${heat_internal}:8000/v1/waitcondition",
  }
}
