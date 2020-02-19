# Installs and configures horizon
class ntnuopenstack::horizon {
  include ::ntnuopenstack::horizon::base
  include ::ntnuopenstack::horizon::plugins
}
