# This class sets up the database for glance
class ntnuopenstack::glance::database {
  $password = lookup('ntnuopenstack::glance::mysql::password', String)
  $allowed_hosts = lookup('ntnuopenstack::mysql::allowed_hosts', {
    'value_type' => Array[String],
    'merge'      => 'first',
  })

  require ::ntnuopenstack::repo

  class { '::glance::db::mysql' :
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
