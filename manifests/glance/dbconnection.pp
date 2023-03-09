# Configures glance's database connection 
class ntnuopenstack::glance::dbconnection {
  $mysql_pass= lookup('ntnuopenstack::glance::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::glance::mysql::ip', Stdlib::IP::Address)
  $database_connection = "mysql+pymysql://glance:${mysql_pass}@${mysql_ip}/glance"

  class { '::glance::api::db':
    database_connection => $database_connection,
  }
}
