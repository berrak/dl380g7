##
## This class manage DNS
##
class hp_bind_rpm::service {
    
	include hp_bind_rpm
	
	service { "named" :
			ensure => running,
		 hasstatus => true,
		hasrestart => true,
			enable => true,
		   require => Package["bind"],
	}
	
}