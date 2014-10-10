##
## Class to change state of service
##
## Sample usage:
##		hp_service::enable { 'ebtables' : }
##
define hp_service::enable {
    	
	# stop service and prevent startup at boot
	service { $name :
		ensure => running,
		enable => true,
	}
	
}
    
    