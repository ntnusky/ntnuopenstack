# Perfomes basic heat configuration
class ntnuopenstack::heat::base {
  # Retrieve service IP Addresses
  $keystone_admin_ip  = hiera('profile::api::keystone::admin::ip', '127.0.0.1')

  # Retrieve api urls, if they exist. 
  $admin_endpoint    = hiera('ntnuopenstack::endpoint::admin', undef)
  $internal_endpoint = hiera('ntnuopenstack::endpoint::internal', undef)

  # Determine which endpoint to use
  $keystone_admin    = pick($admin_endpoint, "http://${keystone_admin_ip}")
  $keystone_internal = pick($internal_endpoint, "http://${keystone_admin_ip}")

  # Misc other settings
  $region = hiera('ntnuopenstack::region')

  # Determine memcahce-server-addresses
  $memcached_ip = hiera('profile::memcache::ip', undef)
  $memcache_servers = hiera_array('profile::memcache::servers', undef)
  $memcache_servers_real = pick($memcache_servers, [$memcached_ip])
  $memcache = $memcache_servers_real.map | $server | {
    "${server}:11211"
  }

  # Transport url
  $transport_url = hiera('ntnuopenstack::transport::url')

  # Database-connection
  $mysql_pass = hiera('ntnuopenstack::heat::mysql::password')
  $mysql_old = hiera('profile::mysql::ip', undef)
  $mysql_new = hiera('profile::haproxy::management::ipv4', undef)
  $mysql_ip = pick($mysql_new, $mysql_old)
  $database_connection = "mysql://heat:${mysql_pass}@${mysql_ip}/heat"

  require ::ntnuopenstack::repo

  # If heat is behind a proxy, make sure to parse the headers from the proxy to
  # create correct urls internally.
  if $keystone_admin =~ /^https.*/ {
    $extra_options = { 'enable_proxy_headers_parsing' => true, }
  } else {
    $extra_options = {}
  }

  class { '::heat':
    # Auth_strategy is blank to prevent ::heat from including 
    # ::heat::keystone::authtoken
    auth_strategy         => '',
    database_connection   => $database_connection,
    default_transport_url => $transport_url,
    region_name           => $region,
    *                     => $extra_options,
  }

  class { '::heat::keystone::authtoken':
    password            => $mysql_pass,
    auth_url            => "${keystone_admin}:35357",
    auth_uri            => "${keystone_internal}:5000/",
    project_domain_name => 'Default',
    user_domain_name    => 'Default',
    memcached_servers   => $memcache,
    region_name         => $region,
  }
}
