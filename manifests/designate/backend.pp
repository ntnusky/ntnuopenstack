# Designate DNS Backend (bind9)
class ntnuopenstack::designate::backend {

  include designate::dns

  class {'designate::backend::bind9':

  }
}
