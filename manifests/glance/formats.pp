# Defines which formats we allow in our glance API.
class ntnuopenstack::glance::formats {
  $container_formats = lookup('ntnuopenstack::glance::container_formats', {
    'value_type'    => Array[String],
    'default_value' => ['bare'],
  })

  $container_formats_real = join($container_formats, ',')

  glance_api_config {
    'image_format/container_formats': value => $container_formats_real;
  }
}
