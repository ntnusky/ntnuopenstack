# Enable the given set of nova workarounds
# The ::nova::workarounds class does not contain everything...

class ntnuopenstack::nova::workarounds (
  $workarounds = []
) {

  $workarounds.each | $workaround | {
    nova_config {
      "workarounds/${workaround}":
        value => true;
    }
  }
}
