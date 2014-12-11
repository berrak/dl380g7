##
## This class manage KVM
##
class hp_kvm_deb::config {










    # Disable 'default' network
	# run this only if 'default' is already started  
	exec { "Disable_default_network" :
			   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
			command => "virsh net-destroy default",
			 onlyif => 'virsh net-list | grep default',
	}
    
    
}
