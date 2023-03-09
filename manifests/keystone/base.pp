# Performs the base configuration of keystone 
class ntnuopenstack::keystone::base {
  $region = lookup('ntnuopenstack::region', String)

  $admin_endpoint  = lookup('ntnuopenstack::keystone::endpoint::admin',
                              Stdlib::Httpurl)
  $public_endpoint = lookup('ntnuopenstack::keystone::endpoint::public',
                              Stdlib::Httpurl)

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

  include ::keystone::healthcheck
  include ::ntnuopenstack::keystone::bootstrap
  include ::ntnuopenstack::keystone::cache
  include ::ntnuopenstack::keystone::dbconnection
  require ::ntnuopenstack::repo

  if($confhaproxy) {
    $logformat = 'forwarded'
  } else {
    $logformat = false
  }

  class { '::keystone':
    credential_keys              => $credential_keys,
    enable_credential_setup      => true,
    enable_fernet_setup          => true,
    enable_proxy_headers_parsing => $confhaproxy,
    fernet_keys                  => $fernet_keys,
    public_endpoint              => "${public_endpoint}:5000/",
    service_name                 => 'httpd',
    sync_db                      => $sync_db,
    token_expiration             => $token_expiration,
    token_provider               => 'fernet',
    using_domain_config          => true,
  }

  class { '::keystone::wsgi::apache':
    access_log_format => $logformat,
    ssl               => false,
  }
}
