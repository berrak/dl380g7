##
## Install logwatch
##
class hp_logwatch::install {

    package { "logwatch": ensure => installed, allow_virtual => true,  }
    
}