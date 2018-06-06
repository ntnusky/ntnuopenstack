# Creates the database for keystone
class ntnuopenstack::keystone::database {
  $password = hiera('ntnuopenstack::keystone::mysql::password')
  $allowed_hosts = hiera('ntnuopenstack::mysql::allowed_hosts')

  require ::ntnuopenstack::repo

  class { '::keystone::db::mysql':
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
