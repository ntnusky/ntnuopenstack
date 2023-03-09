# Configures barbican to use its database
class ntnuopenstack::barbican::dbconnection {
  # Determine database-settings
  $mysql_pass = lookup('ntnuopenstack::barbican::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::barbican::mysql::ip', Stdlib::IP::Address)
  $database_connection = "mysql+pymysql://barbican:${mysql_pass}@${mysql_ip}/barbican"

  class { '::barbican::db':
    database_connection => $database_connection,
  }
}
