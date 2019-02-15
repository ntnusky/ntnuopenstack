# Sets up the cinder database, and lets cinder populate it 
class ntnuopenstack::cinder::database {
  $password = lookup('ntnuopenstack::cinder::mysql::password', String)
  $allowed_hosts = lookup('ntnuopenstack::mysql::allowed_hosts' {
    'value_type' => Array[String],
    'merge'      => 'first',
  })

  require ::ntnuopenstack::repo

  class { '::cinder::db::mysql' :
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
