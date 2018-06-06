# Creates the database for heat
class ntnuopenstack::heat::database {
  $mysql_pass = hiera('ntnuopenstack::heat::mysql::password')
  $allowed_hosts = hiera('ntnuopenstack::mysql::allowed_hosts')

  require ::ntnuopenstack::heat::base

  class { '::heat::db::mysql':
    user          => 'heat',
    password      => $mysql_pass,
    allowed_hosts => $allowed_hosts,
    dbname        => 'heat',
  }
}
