# Installs and configures the heat engine.
class ntnuopenstack::heat::engine {
  $heat_public = lookup('ntnuopenstack::heat::endpoint::public',
                              Stdlib::Httpurl)
  $auth_encryption_key = lookup('ntnuopenstack::heat::auth_encryption_key')

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::heat::base
  include ::ntnuopenstack::heat::deps
  include ::ntnuopenstack::heat::logging::engine

  class { '::heat::engine':
    auth_encryption_key           => $auth_encryption_key,
    heat_metadata_server_url      => "${heat_public}:8000",
    heat_waitcondition_server_url => "${heat_public}:8000/v1/waitcondition",
  }

  cron { 'Remove dead heat-engines':
    command => '/usr/bin/heat-manage service clean',
    minute  => '*/5',
    user    => 'root',
  }
}
