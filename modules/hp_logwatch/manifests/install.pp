##
## Install logwatch
##
class hp_logwatch::install {

    package { "logwatch": ensure => installed }
    
}