# Creates the database for heat
class ntnuopenstack::heat::database {
  $password = lookup('ntnuopenstack::heat::mysql::password', String)
  $allowed_hosts = lookup('ntnuopenstack::mysql::allowed_hosts', {
    'value_type' => Array[String],
    'merge'      => 'first',
  })

  class { '::heat::db::mysql':
    user          => 'heat',
    password      => $password,
    allowed_hosts => $allowed_hosts,
    dbname        => 'heat',
  }
}
