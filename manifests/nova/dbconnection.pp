# Configures nova to use its database
class ntnuopenstack::nova::dbconnection {
  # Determine database-settings
  $mysql_pass = lookup('ntnuopenstack::nova::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::nova::mysql::ip', Stdlib::IP::Address)

  # Create connection-strings
  $dbc = "mysql+pymysql://nova:${mysql_pass}@${mysql_ip}/nova"
  $dbc_api = "mysql+pymysql://nova_api:${mysql_pass}@${mysql_ip}/nova_api"

  # Configure the nova database-connections.
  class { '::nova::db':
    api_database_connection => $dbc_api,
    database_connection => $dbc,
  }
}
