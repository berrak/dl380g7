##
## Install chkrootkit
##
class hp_chkrootkit::install {

    package { "chkrootkit": ensure => installed }

}