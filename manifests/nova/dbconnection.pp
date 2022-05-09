# Performs the common nova configuration.
class ntnuopenstack::nova::dbconnection {
  # Retrieve mysql parameters
  $mysql_password = lookup('ntnuopenstack::nova::mysql::password')
  $mysql_ip = lookup('ntnuopenstack::nova::mysql::ip', {
      'value_type' => Stdlib::IP::Address,
  })

  $db_con = "mysql+pymysql://nova:${mysql_password}@${mysql_ip}/nova"
  $api_db_con = "mysql+pymysql://nova_api:${mysql_password}@${mysql_ip}/nova_api"

  class { '::nova::db':
    api_database_connection => $api_db_con,
    database_connection     => $db_con,
  }
}
