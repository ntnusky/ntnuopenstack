# Sets the default octavia-quotas.
class ntnuopenstack::octavia::quota {
  $load_balancer_quota = lookup(
      'ntnuopenstack::octavia::default::quota::loadbalancers',
      Integer, undef, 1
  )
  $listener_quota = lookup(
      'ntnuopenstack::octavia::default::quota::listeners',
      Integer, undef, -1
  )
  $member_quota = lookup(
      'ntnuopenstack::octavia::default::quota::members',
      Integer, undef, -1
  )
  $pool_quota = lookup(
      'ntnuopenstack::octavia::default::quota::pools',
      Integer, undef, -1
  )
  $health_monitor_quota = lookup(
      'ntnuopenstack::octavia::default::quota::monitors',
      Integer, undef, -1
  )

  class { '::octavia::quota':
    load_balancer_quota  => $load_balancer_quota,
    listener_quota       => $listener_quota,
    member_quota         => $member_quota,
    pool_quota           => $pool_quota,
    health_monitor_quota => $health_monitor_quota,
  }
}
