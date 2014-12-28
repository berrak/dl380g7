##
## This class manage iptables
##
class hp_iptables_rpm::install {

    
    if ! ( $::operatingsystem == 'OracleLinux' ) {
        fail("FAIL: Aborting. This module (iptables) is only for OracleLinux based distributions!")
    }
    
    package  { 'iptables' :
                ensure => installed,
                allow_virtual => true,
    }

}
