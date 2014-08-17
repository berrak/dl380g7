##
## Install screen
##
class hp_screen::install {

    package { "screen": ensure => installed }
    
}