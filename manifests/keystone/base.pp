# Performs the base configuration of keystone 
class ntnuopenstack::keystone::base {
  $region = lookup('ntnuopenstack::region', String)

  $admin_endpoint  = lookup('ntnuopenstack::keystone::endpoint::admin',
                              Stdlib::Httpurl)
  $public_endpoint = lookup('ntnuopenstack::keystone::endpoint::public',
                              Stdlib::Httpurl)

  $mysql_password = lookup('ntnuopenstack::keystone::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::keystone::mysql::ip', Stdlib::IP::Address)
  $db_con = "mysql://keystone:${mysql_password}@${mysql_ip}/keystone"

  $sync_db = lookup('ntnuopenstack::keystone::db::sync', Boolean)

  $confhaproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  $credential_keys = lookup('ntnuopenstack::keystone::credential::keys', {
    'value_type' => Hash[Stdlib::Unixpath, Hash[String, String]],
    'merge'      => 'hash',
  })
  $fernet_keys = lookup('ntnuopenstack::keystone::fernet::keys', {
    'value_type' => Hash[Stdlib::Unixpath, Hash[String, String]],
    'merge'      => 'hash',
  })

  $token_expiration = lookup('ntnuopenstack::keystone::token::expiration', {
    'value_type'    => Integer,
    'default_value' => 14400,   # Default token lifetime is 14400 seconds (4h)
  })

  include ::ntnuopenstack::keystone::bootstrap
  include ::ntnuopenstack::keystone::cache
  require ::ntnuopenstack::repo

  if($confhaproxy) {
    $logformat = 'forwarded'
  } else {
    $logformat = false
  }

  class { '::keystone':
    database_connection          => $db_con,
    enabled                      => false,
    service_name                 => 'httpd',
    admin_endpoint               => "${admin_endpoint}:5000/",
    public_endpoint              => "${public_endpoint}:5000/",
    token_provider               => 'fernet',
    fernet_keys                  => $fernet_keys,
    enable_fernet_setup          => true,
    credential_keys              => $credential_keys,
    enable_credential_setup      => true,
    enable_proxy_headers_parsing => $confhaproxy,
    using_domain_config          => true,
    token_expiration             => $token_expiration,
    sync_db                      => $sync_db,
  }

  class { '::keystone::wsgi::apache':
    ssl               => false,
    access_log_format => $logformat,
  }
  ensure_packages( ['python3-mysqldb'] , {
    'ensure' => 'present',
  })
}
