# Common glance settings for nova
class ntnuopenstack::nova::common::glance {
  $region = lookup('ntnuopenstack::region')

  nova_config {
    'glance/region_name': value => $region;
  }
}
