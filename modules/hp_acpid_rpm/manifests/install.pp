#
# Ensure acpid is instaled on minimal OracleLinux-6
# (otherwise 'virsh shutdown <guest>' does not work)
#
class hp_acpid_rpm::install {

    if ($::operatingsystem != 'OracleLinux' ) {
        fail ("FAIL: This module is only for OracleLinux systems! Aborting...")
    }
    
    package  { 'acpid' :
                ensure => installed,
                allow_virtual => true,
    }

}
