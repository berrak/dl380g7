##
## Manage NFSv4 client
##
class hp_nfs4client_deb::install {


    if ( $::operatingsystem != 'Debian' ) {
    
        fail("FAIL: This NFS4-client module is only for Debian -- Aborting!")

    } else {
    
        package { "nfs-common" :
                   ensure => installed,
            allow_virtual => true,
        }
    
    }
    
}
