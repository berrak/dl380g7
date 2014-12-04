#
# Manage apache2 (RPM version)
#
class hp_apache2_rpm::install {

    if ! ( $::operatingsystem == 'OracleLinux' ) {
        fail("FAIL: Aborting. This module (hp_apache2_rpm) is only for OracleLinux based distributions!")
    }
    
    package { "httpd" :
               ensure => installed,
        allow_virtual => true,
    }
    
}