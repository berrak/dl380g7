##
## This class manage LXC
##
class hp_kvm_lxc::service {
    	
	service { "cgconfig" :
			ensure => running,
			enable => true,
		   require => Package["lxc"],
	}
		
}