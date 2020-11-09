# Configures cache for keystone
class ntnuopenstack::keystone::cache {
  $cache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Variant[Array[String], Boolean],
    'default_value' => false,
    'merge'         => 'unique',
  })

  if($cache_servers) {
    $memcache_servers = $cache_servers.map | $server | {
      "${server}:11211"
    }

    class { '::keystone::cache':
      backend          => 'oslo_cache.memcache_pool',
      enabled          => true,
      memcache_servers => $memcache_servers,
      token_caching    => true,
    }
  }
}
