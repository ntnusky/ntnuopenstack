# Installs and configures horizon
class ntnuopenstack::horizon {
  include ::ntnuopenstack::horizon::base
  include ::ntnuopenstack::horizon::logging
  include ::ntnuopenstack::horizon::plugins
}
