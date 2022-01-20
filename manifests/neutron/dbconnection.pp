# Configures neutrons database connection 
class ntnuopenstack::neutron::dbconnection {
  $mysql_password = lookup('ntnuopenstack::neutron::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::neutron::mysql::ip', Stdlib::IP::Address)
  $conn = "mysql+pymysql://neutron:${mysql_password}@${mysql_ip}/neutron"

  class { '::neutron::db':
    database_connection => $conn,
  }
}
