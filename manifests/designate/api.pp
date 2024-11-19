# Configures a Designate API server, running most designate components
class ntnuopenstack::designate::api {
  require ::ntnuopenstack::repo

  $api_port = lookup('ntnuopenstack::designate::api::port')

  require ::ntnuopenstack::designate::base
  require ::ntnuopenstack::designate::backend
  require ::ntnuopenstack::designate::auth
  contain ::ntnuopenstack::designate::haproxy::backend
  include ::ntnuopenstack::designate::sudo

  class { '::designate::api':
    auth_strategy    => 'keystone',
    enable_api_v2    => true,
    enable_api_admin => true,
    service_name     => 'httpd',
  }

  class { '::designate::wsgi::apache':
    access_log_format => 'forwarded',
    workers           => 2,
    port              => Integer($api_port),
  }
}
