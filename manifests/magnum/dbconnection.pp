# Configre magnum to use its database
class ntnuopenstack::magnum::dbconnection {
  # Determine database-settings
  $mysql_pass = lookup('ntnuopenstack::magnum::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::magnum::mysql::ip', Stdlib::IP::Address)
  $database_connection = "mysql+pymysql://magnum:${mysql_pass}@${mysql_ip}/magnum"

  class { '::magnum::db':
    database_connection => $database_connection,
  }
}
