# Configures the haproxy frontend for the public swift API, if the swift-api is
# placed on a dedicated name at port 80/443.
class ntnuopenstack::swift::haproxy::web {
  include ::profile::services::haproxy::web

  profile::services::haproxy::tools::collect { 'bk_swift_public': }

  haproxy::backend { 'bk_swift_public':
    mode    => 'http',
    options => {
      'balance' => 'source',
      'option'  => [
        'httpchk HEAD /',
        'forwardfor',
        'http-server-close',
      ],
      'timeout' => [
        'http-keep-alive 500',
      ],
    },
  }
}
