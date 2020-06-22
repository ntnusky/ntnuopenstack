# Creates database for magnum
class ntnuopenstack::magnum::database {
  $password = lookup('ntnuopenstack::magnum::mysql::password', String)
  $allowed_hosts = lookup('ntnuopenstack::mysql::allowed_hosts', {
    'value_type' => Array[String],
    'merge'      => 'first',
  })

  require ::ntnuopenstack::repo

  class { '::magnum::db::mysql':
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
