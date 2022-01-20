# Install some client-libraries suddenly required for the heat-engine to start.
class ntnuopenstack::heat::deps {
  package { [ 'python3-vitrageclient', 'python3-etcd3gw', 'python3-zunclient' ]:
    ensure => 'present',
  }
}
