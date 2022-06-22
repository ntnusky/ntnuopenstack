# Configures Keystones DB connection. 
class ntnuopenstack::keystone::dbconnection {
  $mysql_password = lookup('ntnuopenstack::keystone::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::keystone::mysql::ip', Stdlib::IP::Address)
  $db_con = "mysql+pymysql://keystone:${mysql_password}@${mysql_ip}/keystone"

  class { '::keystone::db':
    database_connection          => $db_con,
  }
}
