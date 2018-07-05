# Configures the base cinder config
class ntnuopenstack::cinder::base {
  # Determine where the database resides 
  $mysql_pass = hiera('ntnuopenstack::cinder::mysql::password')
  $mysql_old = hiera('profile::mysql::ip', undef)
  $mysql_new = hiera('profile::haproxy::management::ipv4', undef)
  $mysql_ip = pick($mysql_new, $mysql_old)
  $database_connection = "mysql://cinder:${mysql_pass}@${mysql_ip}/cinder"

  # Credentials for the messagequeue
  $transport_url = hiera('ntnuopenstack::transport::url')

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::cinder::sudo

  class { '::cinder':
    database_connection   => $database_connection,
    default_transport_url => $transport_url,
  }
}
