# Defines which formats we allow in our glance API.
class ntnuopenstack::glance::formats {
  $disk_formats = lookup('ntnuopenstack::glance::disk_formats', {
    'value_type'    => Hash[String, String],
    'default_value' => {'raw' => '', 'qcow2' => ''}
  })
  $container_formats = lookup('ntnuopenstack::glance::container_formats', {
    'value_type'    => Array[String],
    'default_value' => ['bare'],
  })

  $disk_formats_real = join(keys($disk_formats), ',')
  $container_formats_real = join($container_formats, ',')

  glance_api_config {
    'image_format/container_formats': value => $container_formats_real;
    'image_format/disk_formats':      value => $disk_formats_real;
  }
}
