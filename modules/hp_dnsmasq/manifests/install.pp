##
## This class manage DNS, resolv.conf and the 'hosts' file
##
class hp_dnsmasq::install {

    package { "dnsmasq" :
               ensure => present,
        allow_virtual => true,
    }

    # ensure recognized opearting system
    if ( $::operatingsystem in [ 'OracleLinux', 'Debian' ] ) {

    	fail("FAIL: Unknown $::operatingsystem distribution. Aborting...")
    }

}
