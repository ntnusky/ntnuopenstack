# Creates the databases for designate.
class ntnuopenstack::designate::database {
  $mysql_password = lookup('ntnuopenstack::designate::mysql::password', String)
  $allowed_hosts = lookup('ntnuopenstack::mysql::allowed_hosts', {
    'value_type' => Array[String],
    'merge'      => 'first',
  })

  class {'::designate::db::mysql':
    allowed_hosts => $allowed_hosts,
    password      => $mysql_password,
  }
}
