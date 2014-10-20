##
## This class manage KVM
##
class hp_kvm_rpm::service {
    	
	service { "libvirt" :
			ensure => running,
			enable => true,
		   require => Package["libvirt"],
	}
	
}