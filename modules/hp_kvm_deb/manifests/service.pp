##
## This class manage KVM
##
class hp_kvm_deb::service {
    	
	service { "libvirt" :
			ensure => running,
			enable => true,
		   require => Package["libvirt-bin"],
	}
		
}
