#
# Manage apache2 reverse proxy for NAT VM's
#
class hp_apache_rev_proxy::install {

    if ! ( $::lsbdistid == 'OracleServer' ) {
        fail("FAIL: Aborting. This module (apache_rev_proxy) is only for OracleLinux based distributions!")
    }
    
    package { "httpd" :
               ensure => installed,
        allow_virtual => true,
    }
    
}