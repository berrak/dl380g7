#
# Install the rsyslog package.
#
class hp_rsyslog::install {

    package { 'rsyslog':
        ensure => installed,
    }
        
    # TLS for rsyslog
    
    package { 'rsyslog-gnutls' :
         ensure => installed,
        require => Package["rsyslog"],
    }
    
}