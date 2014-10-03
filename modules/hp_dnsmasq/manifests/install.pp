##
## This class manage DNS, resolv.conf and the 'hosts' file
##
class hp_dnsmasq::install {

    package { "dnsmasq" :
               ensure => present,
        allow_virtual => true,
    }

    # ensure service is enabled at boot
    if $::lsbdistid == 'OracleServer'  {
        
        exec { 'Enable_OL6_dnsmasq_at_boot':
		command => '/sbin/chkconfig dnsmasq on',
		 path   => '/usr/bin:/usr/sbin:/bin:/sbin',
		require => Package['dnsmasq'],
         onlyif => "chkconfig | grep 'dnsmasq ' | grep 3:off",
        }
          
    } else {
    	fail("FAIL: Unknown $::lsbdistid distribution. Aborting...")
    }

}
