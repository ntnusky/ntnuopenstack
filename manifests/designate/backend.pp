# Designate DNS Backend (bind9)
class ntnuopenstack::designate::backend {
  class {'::designate::backend::bind9':

  }
}
