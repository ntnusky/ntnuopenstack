# Sets up the cinder database, and lets cinder populate it 
class ntnuopenstack::cinder::database {
  $password = hiera('ntnuopenstack::cinder::mysql::password')
  $allowed_hosts = hiera('ntnuopenstack::mysql::allowed_hosts')

  require ::ntnuopenstack::repo

  class { '::cinder::db::mysql' :
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
