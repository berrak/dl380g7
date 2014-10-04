##
## This class manage iptables and fail2ban
##
class hp_iptables_rpm::install {

    
    if ! ( $::lsbdistid == 'OracleServer' ) {
        fail("FAIL: Aborting. This module (iptables) is only for OracleLinux based distributions!")
    }
    
    package  { 'iptables' :
                ensure => installed,
                allow_virtual => true,
    }

}
