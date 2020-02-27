# Configure crypto plugin for barbican
class ntnuopenstack::barbican::crypto {
  $kek = lookup('ntnuopenstack::barbican::simple_crypto::kek', Stdlib::Base64)

  class { '::barbican::plugins::simple_crypto':
    simple_crypto_plugin_kek => $kek,
    global_default    => true,
  }
}
