# Configures a database-user for zabbix monitoring of openstack
class ntnuopenstack::zabbix::database {
  $username = lookup('ntnuopenstack::zabbix::database::username', {
    'default_value' => 'zabbix_ro',
    'value_type'    => String,
  })
  $password = lookup('ntnuopenstack::zabbix::database::password', {
    'value_type'    => String,
  })

  $databases = [
    'cinder',
    'glance',
    'heat',
    'keystone',
    'magnum', 
    'neutron',
    'nova', 
    'octavia',
  ]

  mysql_user { "${username}@%":
    ensure        => 'present',
    password_hash => mysql::password($password),
  }

  $databases.each | $database | {
    mysql_grant { "${username}@%/${database}.*":
      ensure     => 'present',
      options    => ['GRANT'],
      privileges => ['SELECT'],
      table      => "${database}.*",
      user       => "${username}@%",
      require    => Mysql_user["${username}@%"],
    }
  }
}
