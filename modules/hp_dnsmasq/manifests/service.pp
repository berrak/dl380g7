##
## This class manage DNS, resolv.conf and the 'hosts' file
##
class hp_dnsmasq::service {
    
	service { 'dnsmasq' :
			ensure => running,
		 hasstatus => true,
		hasrestart => true,
			enable => true,
		   require => Package['dnsmasq'],
	}
	
}