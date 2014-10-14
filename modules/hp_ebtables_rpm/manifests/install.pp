##
## This class manage ebtables
##
class hp_ebtables_rpm::install {

    
    if ! ( $::lsbdistid == 'OracleServer' ) {
        fail("FAIL: Aborting. This module (ebtables) is only for OracleLinux based distributions!")
    }
    
    package  { 'ebtables' :
                ensure => installed,
                allow_virtual => true,
    }

}
