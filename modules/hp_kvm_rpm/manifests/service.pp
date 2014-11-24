##
## This class manage KVM
##
class hp_kvm_rpm::service {
    	
	service { "libvirtd" :
			ensure => running,
			enable => true,
		   require => Package["libvirt"],
	}
		
}