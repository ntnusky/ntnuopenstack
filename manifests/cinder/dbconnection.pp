# Configures the cinder database 
class ntnuopenstack::cinder::dbconnection {
  $mysql_pass = lookup('ntnuopenstack::cinder::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::cinder::mysql::ip', Stdlib::IP::Address)
  $database_connection = "mysql+pymysql://cinder:${mysql_pass}@${mysql_ip}/cinder"

  class { '::cinder::db':
    database_connection   => $database_connection,
  }
}
