# Creates the databases for the placement service.
class ntnuopenstack::placement::database {
  $mysql_password = lookup('ntnuopenstack::placement::mysql::password', String)
  $allowed_hosts = lookup('ntnuopenstack::mysql::allowed_hosts', {
    'value_type' => Array[String],
    'merge'      => 'first',
  })

  class { '::placement::db::mysql' :
    password      => $mysql_password,
    allowed_hosts => $allowed_hosts,
  }
}
