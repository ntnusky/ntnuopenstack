# Sets up the neutron database
class ntnuopenstack::neutron::database {
  $password = hiera('ntnuopenstack::neutron::mysql::password')
  $allowed_hosts = hiera('ntnuopenstack::mysql::allowed_hosts')

  class { '::neutron::db::mysql' :
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
