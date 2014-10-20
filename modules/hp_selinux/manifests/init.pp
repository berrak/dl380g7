##
## Class to manage SELinux
##
class hp_selinux {

    package { "policycoreutils-python" :
               ensure => present,
        allow_virtual => true,
    }

}
