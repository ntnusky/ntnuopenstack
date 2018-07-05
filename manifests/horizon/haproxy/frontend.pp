# Configures the haproxy frontend for horizon
class ntnuopenstack::horizon::haproxy::frontend {
  include ::profile::services::haproxy::web

  profile::services::haproxy::tools::collect { 'bk_horizon': }

  haproxy::backend { 'bk_horizon':
    mode    => 'http',
    options => {
      'balance' => 'source',
      'option'  => [
        'httplog',
        'httpchk',
        'tcpka',
        'tcplog',
      ],
    },
  }
}
