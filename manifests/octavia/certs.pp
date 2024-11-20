# Configures the octavia CA 
class ntnuopenstack::octavia::certs {
  $server_ca_cert = lookup('ntnuopenstack::octavia::certs::serverca::cert')
  $server_ca_key = lookup('ntnuopenstack::octavia::certs::serverca::key')
  $server_ca_passphrase = lookup(
      'ntnuopenstack::octavia::certs::serverca::passphrase')
  $amphora_certs_keyphrase = lookup(
      'ntnuopenstack::octavia::certs::server::passphrase')
  $client_ca_cert = lookup('ntnuopenstack::octavia::certs::clientca::cert')
  $client_cert = lookup('ntnuopenstack::octavia::certs::client::cert')
  $region = lookup('ntnuopenstack::region', String)

  class { '::octavia::certificates':
    region_name                 => $region,
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
