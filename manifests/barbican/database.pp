# Creates database for barbican
class ntnuopenstack::barbican::database {
  $password = lookup('ntnuopenstack::barbican::mysql::password', String)
  $allowed_hosts = lookup('ntnuopenstack::mysql::allowed_hosts', {
    'value_type' => Array[String],
    'merge'      => 'first',
  })

  require ::ntnuopenstack::repo

  class { '::barbican::db::mysql':
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
