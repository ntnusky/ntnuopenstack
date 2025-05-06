# Configures designate to use its database
class ntnuopenstack::designate::dbconnection {
  # Determine database-settings
  $dbsync = lookup('ntnuopenstack::designate::mysql::sync', {
    'default_value' => false,
    'value_type'    => Boolean,
  })
  $mysql_pass = lookup('ntnuopenstack::designate::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::designate::mysql::ip', Stdlib::IP::Address)
  $database_connection = "mysql+pymysql://designate:${mysql_pass}@${mysql_ip}/designate"

  class { '::designate::db':
    database_connection => $database_connection,
    sync_db             => $dbsync,
  }
}
