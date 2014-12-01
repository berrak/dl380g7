##
## This class manage LXC
##
class hp_lxc_rpm::service {
    	
	service { "cgconfig" :
			ensure => running,
			enable => true,
		   require => Package["lxc"],
	}
		
}