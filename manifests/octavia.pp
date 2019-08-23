# Installs and configures the octavia controller profile.
class ntnuopenstack::octavia {
  $api_port = lookup('ntnuopenstack::octavia::api::port', Stdlib::Port)
  $dbsync = lookup('ntnuopenstack::octavia::db::sync', Boolean, 'first', false)

  $flavor_id = lookup('ntnuopenstack::octavia::flavor::id', String)
  $image_tag = lookup('ntnuopenstack::octavia::image::tag', String, 'first',
                      'amphora')
  $secgroup_id = lookup('ntnuopenstack::octavia::secgroup::id', String)
  $network_id = lookup('ntnuopenstack::octavia::network::id', String)
  $keypair = lookup('ntnuopenstack::octavia::ssh::keypair::name', String)
  $heartbeat_key = lookup('ntnuopenstack::octavia::heartbeat::key', String)
  $health_managers = lookup('ntnuopenstack::octavia::health::managers',
                        Array[String])
  $spare_pool_size = lookup('ntnuopenstack::octavia::amphora::spares', Integer,
      'first', 0)
  $management_if = lookup('profile::interfaces::management', String)
  $mip = $facts['networking']['interfaces'][$management_if]['ip']
  $management_ipv4 = lookup(
    "profile::baseconfig::network::interfaces.${management_if}.ipv4.address", {
      'value_type'    => Stdlib::IP::Address::V4,
      'default_value' => $mip,
  })

  $server_ca_cert = lookup('ntnuopenstack::octavia::certs::serverca::cert')
  $server_ca_key = lookup('ntnuopenstack::octavia::certs::serverca::key')
  $server_ca_passphrase = lookup(
      'ntnuopenstack::octavia::certs::serverca::passphrase')
  $amphora_certs_keyphrase = lookup(
      'ntnuopenstack::octavia::certs::server::passphrase')
  $client_ca_cert = lookup('ntnuopenstack::octavia::certs::clientca::cert')
  $client_cert = lookup('ntnuopenstack::octavia::certs::client::cert')

  $keystone_password = lookup('ntnuopenstack::octavia::keystone::password')
  $internal_endpoint = lookup('ntnuopenstack::endpoint::internal')

  include ::ntnuopenstack::octavia::base
  include ::ntnuopenstack::octavia::firewall::controller
  include ::ntnuopenstack::octavia::haproxy::backend
  require ::ntnuopenstack::repo

  class { '::octavia::api':
    port           => $api_port,
    sync_db        => $dbsync,
    api_v1_enabled => false,
  }

  class { '::octavia::controller':
    amp_flavor_id         => $flavor_id,
    amp_image_tag         => $image_tag,
    amp_secgroup_list     => [$secgroup_id],
    amp_boot_network_list => [$network_id],
    loadbalancer_topology => 'SINGLE',
    amp_ssh_key_name      => $keypair,
  }

  $controller_ip_port_list = join($health_managers, ', ')
  octavia_config {
    'health_manager/controller_ip_port_list': value => $controller_ip_port_list;
  }

  class { '::octavia::worker':
    manage_nova_flavor => false,
    amp_project_name   => 'services',
  }

  class { '::octavia::service_auth':
    auth_url            => "${internal_endpoint}:35357/v3",
    username            => 'octavia',
    project_name        => 'services',
    password            => $keystone_password,
    user_domain_name    => 'default',
    project_domain_name => 'default',
    auth_type           => 'password',
  }

  class { '::octavia::health_manager':
    ip            => $management_ipv4,
    heartbeat_key => $heartbeat_key,
  }

  class { '::octavia::housekeeping':
    spare_amphora_pool_size => $spare_pool_size,
  }

  class { '::octavia::certificates':
    cert_generator              => local_cert_generator,

    # The CA certificate used to sign the amphora certs
    ca_certificate              => '/etc/octavia/certs/server_ca.cert.pem',
    ca_certificate_data         => $server_ca_cert,
    ca_private_key              => '/etc/octavia/certs/server_ca.key.pem',
    ca_private_key_data         => $server_ca_key,
    ca_private_key_passphrase   => $server_ca_passphrase,
    server_certs_key_passphrase => $amphora_certs_keyphrase,

    # The CA certificate used to sign the octavia-controller's certificates.
    client_ca                   => '/etc/octavia/certs/client_ca.cert.pem',
    client_ca_data              => $client_ca_cert,

    # The certificate for the octavia-controller.
    client_cert                 => '/etc/octavia/certs/client.cert.pem',
    client_cert_data            => $client_cert,
  }

}
