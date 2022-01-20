# Configures placement to use its database
class ntnuopenstack::placement::dbconnection {
  # Determine database-settings
  $mysql_pass = lookup('ntnuopenstack::placement::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::placement::mysql::ip', Stdlib::IP::Address)
  $database_connection = "mysql+pymysql://placement:${mysql_pass}@${mysql_ip}/placement"

  class { '::placement::db':
    database_connection => $database_connection,
  }
}
