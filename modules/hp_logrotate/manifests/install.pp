#
# Install the logrotate package (if not already installed default)
#
class hp_logrotate::install {

    package { 'logrotate' :
               ensure => installed,
        allow_virtual => true, 
    }
    
}