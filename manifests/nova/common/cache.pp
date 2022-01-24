# Configures nova to use memcache
class ntnuopenstack::nova::common::cache {
  # Retrieve memcache configuration
  $memcache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[Stdlib::IP::Address],
    'default_value' => [],
  })
  $memcache = $memcache_servers.map | $server | {
    "${server}:11211"
  }

  class { '::nova::cache' :
    enabled          => true,
    backend          => 'oslo_cache.memcache_pool',
    memcache_servers => $memcache,
  }
}
