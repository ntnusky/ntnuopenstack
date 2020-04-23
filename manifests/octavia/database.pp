# Creates the database for octavia
class ntnuopenstack::octavia::database {
  $password = lookup('ntnuopenstack::octavia::mysql::password', String)
  $allowed_hosts = lookup('ntnuopenstack::mysql::allowed_hosts', {
    'value_type' => Array[String],
    'merge'      => 'first',
  })

  require ::ntnuopenstack::repo

  class { '::octavia::db::mysql':
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
