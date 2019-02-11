# Sets up the neutron database
class ntnuopenstack::neutron::database {
  $password = lookup('ntnuopenstack::neutron::mysql::password', String)
  $allowed_hosts = lookup('ntnuopenstack::mysql::allowed_hosts' {
    'value_type' => Array[String],
    'merge'      => 'first',
  })

  class { '::neutron::db::mysql' :
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
