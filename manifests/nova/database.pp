# Creates the databases for nova.
class ntnuopenstack::nova::database {
  $mysql_password = hiera('ntnuopenstack::nova::mysql::password')
  $allowed_hosts = hiera('ntnuopenstack::mysql::allowed_hosts')

  class { '::nova::db::mysql' :
    password      => $mysql_password,
    allowed_hosts => $allowed_hosts,
  }

  class { '::nova::db::mysql_api' :
    password      => $mysql_password,
    allowed_hosts => $allowed_hosts,
  }
}
