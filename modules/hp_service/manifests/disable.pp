##
## Class to change state of service
##
## Sample usage:
##		hp_service::disable { 'cups' : }
##
define hp_service::disable {
    	
	# stop service and prevent startup at boot
	service { $name :
		ensure => stopped,
		enable => false,
	}
	
}
    
    