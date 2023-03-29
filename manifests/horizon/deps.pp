# Install dependecies for specific distros
class ntnuopenstack::horizon::deps {
  $distro = $facts['os']['release']['major']

  # This is needed because the manage.py script has a shebang-line
  # that expects "python" to exist...
  if($distro == '22.04') {
    ensure_packages('python-is-python3', {
      'ensure' => 'present'
    })
  }
}
