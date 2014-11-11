##
## This class manage DNS
##
class hp_bind_rpm::install {

    package { [ "bind", "bind-utils" ] :
               ensure => present,
        allow_virtual => true,
    }

}
