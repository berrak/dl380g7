##
## Class to manage user with sudo capability.
##
class hp_sudo::install {

    package { "sudo" :
               ensure => present,
        allow_virtual => true,
    }

}