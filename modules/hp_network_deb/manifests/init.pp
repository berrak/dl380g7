#
# Manage networking
#
class hp_network_deb {

    if ( $::operatingsystem != 'Debian' ) {
        fail("FAIL: This module is intended only for Debian!")
    }

    include hp_network_rpm::install, hp_network_rpm::service

}