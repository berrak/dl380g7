#
# Simple module to install RedHat packages which
# does not require any complicated setups
#
class hp_install_rpms ( $rpms ='' ) {

    if $rpms == '' {
        fail("FAIL: Missing list of RedHat package names ($rpms) to install!")
    }

    # rpms is an array of rpm package names, defined in site.pp
    
    package { $rpms : ensure => installed, allow_virtual => true, }

}