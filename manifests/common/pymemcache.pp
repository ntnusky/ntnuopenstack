# This class installs the python3 memecache-bindings
class ntnuopenstack::common::pymemcache {
  ensure_packages ( [ 'python3-memcache' ], {
    'ensure' => 'present',
  })
}
