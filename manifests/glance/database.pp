# This class sets up the database for glance
class ntnuopenstack::glance::database {
  $password = hiera('ntnuopenstack::glance::mysql::password')
  $allowed_hosts = hiera('ntnuopenstack::mysql::allowed_hosts')

  require ::ntnuopenstack::repo

  class { '::glance::db::mysql' :
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
