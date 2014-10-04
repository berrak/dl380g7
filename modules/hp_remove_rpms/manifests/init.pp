#
# Simple module to remove RedHat packages
# which may be a security risk on a server.
#
class hp_remove_rpms ( $rpms ='' ) {

    if $rpms == '' {
        fail("FAIL: Missing list of RedHat package names ($rpms) to remove!")
    }

    # rpms is an array of rpm package names, defined in site.pp
    
    package { $rpms :
               ensure => purged,
        allow_virtual => true,
    }

}