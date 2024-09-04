# Designate DNS Backend (bind9)
class ntnuopenstack::designate::api {

  include designate::dns

  class {'designate::backend::bind9':

  }
}
