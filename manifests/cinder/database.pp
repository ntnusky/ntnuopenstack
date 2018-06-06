# Sets up the cinder database, and lets cinder populate it 
class ntnuopenstack::cinder::database {
  $password = hiera('ntnusky::cinder::mysql::password')
  $allowed_hosts = hiera('ntnusky::mysql::allowed_hosts')

  require ::ntnuopenstack::repo

  class { '::cinder::db::mysql' :
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
