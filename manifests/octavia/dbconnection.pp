# Configures octavia to use its database
class ntnuopenstack::octavia::dbconnection {
  # Determine database-settings
  $mysql_pass = lookup('ntnuopenstack::octavia::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::octavia::mysql::ip', Stdlib::IP::Address)
  $database_connection = "mysql+pymysql://octavia:${mysql_pass}@${mysql_ip}/octavia"

  class { '::octavia::db':
    database_connection => $database_connection,
  }
}
