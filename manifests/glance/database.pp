# This class sets up the database for glance
class ntnuopenstack::glance::database {
  $password = hiera('profile::mysql::glancepass')
  $allowed_hosts = hiera('profile::mysql::allowed_hosts')

  require ::ntnuopenstack::repo

  class { '::glance::db::mysql' :
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
