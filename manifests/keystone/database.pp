# Creates the database for keystone
class ntnuopenstack::keystone::database {
  $password = lookup('ntnuopenstack::keystone::mysql::password', String)
  $allowed_hosts = lookup('ntnuopenstack::mysql::allowed_hosts', {
    'value_type' => Array[String],
    'merge'      => 'first',
  })

  require ::ntnuopenstack::repo

  class { '::keystone::db::mysql':
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
