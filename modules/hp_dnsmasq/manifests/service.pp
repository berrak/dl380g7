##
## This class manage DNS, resolv.conf and the 'hosts' file
##
class hp_dnsmasq::service {
    
	include hp_dnsmasq
	
	service { "dnsmasq" :
			ensure => stopped,
		 hasstatus => true,
		hasrestart => true,
			enable => false,
		   require => Package["dnsmasq"],
	}
	
}