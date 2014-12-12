##
## This class manage KVM
##
class hp_kvm_deb {

    if ( $::operatingsystem != 'Debian' ) {
        fail("FAIL: This module is intended only for Debian!")
    }

    include hp_kvm_deb::install, hp_kvm_deb::config, hp_kvm_deb::add_guest

}
