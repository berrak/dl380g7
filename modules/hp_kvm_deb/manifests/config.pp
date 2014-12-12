##
## This class manage KVM
##
class hp_kvm_deb::config {


	# set up storage pool
	file { '/data':
		owner => 'root',
		group => 'root',
	}	
	
	# create a subdirectory for vm images (which already is LVM)
	file { "/data/vm-images":
		 ensure => "directory",
		 owner => 'root',
		 group => 'root',
		require => File['/data'],
	}
	
    # Disable 'default' network
	# run this only if 'default' is already started  
	exec { "Disable_default_network" :
			   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
			command => "virsh net-destroy default",
			 onlyif => 'virsh net-list | grep default',
	}
    
    
}
