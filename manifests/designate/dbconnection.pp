# Configures designate to use its database
class ntnuopenstack::designate::dbconnection {
  # Determine database-settings
  $mysql_pass = lookup('ntnuopenstack::designate::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::designate::mysql::ip', Stdlib::IP::Address)
  $database_connection = "mysql+pymysql://designate:${mysql_pass}@${mysql_ip}/designate"

  class { '::designate::db':
    database_connection => $database_connection,
  }

  class {'::designate::db::mysql':
    password => $mysql_pass,
  }
}