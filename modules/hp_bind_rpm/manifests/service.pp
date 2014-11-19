##
## This class manage DNS
##
class hp_bind_rpm::service {
    
	include hp_bind_rpm
	
	service { "named" :
			ensure => stopped,
		 hasstatus => true,
		hasrestart => true,
			enable => false,
		   require => Package["bind"],
	}
	
}