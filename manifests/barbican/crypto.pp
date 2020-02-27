# Configure crypto plugin for barbican
class ntnuopenstack::barbican::crypto {
  $simple_crypto_kek = lookup('ntnuopenstack::barbican::simple_crypto::kek', Stdlib::Base64)

  class { '::barbican::plugins::simple_crypto':
    simple_crypto_kek => $simple_crypto_kek,
    global_default    => true,
  }
}
