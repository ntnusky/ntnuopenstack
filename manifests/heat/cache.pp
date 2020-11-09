# Configures heat to use memcache
class ntnuopenstack::heat::cache {
  $cache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[String],
    'merge'         => 'unique',
  })
  $memcache_servers = $cache_servers.map | $server | {
    "${server}:11211"
  }

  class { '::heat::cache':
    backend          => 'oslo_cache.memcache_pool',
    enabled          => true,
    memcache_servers => $memcache_servers,
  }
}
