# Creates the databases for nova.
class ntnuopenstack::nova::database {
  $mysql_password = lookup('ntnuopenstack::nova::mysql::password', String)
  $allowed_hosts = lookup('ntnuopenstack::mysql::allowed_hosts' {
    'value_type' => Array[String],
    'merge'      => 'first',
  })

  class { '::nova::db::mysql' :
    password      => $mysql_password,
    allowed_hosts => $allowed_hosts,
  }

  class { '::nova::db::mysql_api' :
    password      => $mysql_password,
    allowed_hosts => $allowed_hosts,
  }
}
