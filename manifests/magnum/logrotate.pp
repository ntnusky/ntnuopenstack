# Logrotat config, since UCA packages don't include it
class ntnuopenstack::magnum::logrotate {
  logrotate::rule { 'magnum':
    path          => '/var/log/magnum/*.log',
    compress      => true,
    copytruncate  => true,
    delaycompress => true,
    missingok     => true,
    rotate_every  => 'day',
  }
}
