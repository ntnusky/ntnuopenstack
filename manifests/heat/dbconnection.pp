# Configures heats connection to the DB.
class ntnuopenstack::heat::dbconnection {
  # Database-connection
  $mysql_pass = lookup('ntnuopenstack::heat::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::heat::mysql::ip', Stdlib::IP::Address)
  $database_connection = "mysql+pymysql://heat:${mysql_pass}@${mysql_ip}/heat"

  class { '::heat::db':
    database_connection          => $database_connection,
  }
}
