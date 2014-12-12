##
## This class manage KVM
##
class hp_kvm_deb::config {


	# set up storage pool
	file { '/data':
		owner => 'root',
		group => 'root',
	}	
	
	# create a subdirectory for vm images
	file { "/data/vm-images":
		 ensure => "directory",
		 owner => 'root',
		 group => 'root',
		require => File['/data'],
	}
	
	# create the pool for storage of our vm images
	exec { 'create_pool_vm_images' :
		   path => "/bin:/sbin:/usr/bin:/usr/sbin",
		command => "virsh pool-create-as vm-images dir --target /data/vm-images",
		 unless => "virsh pool-list | grep vm-images",
		require => File['/data/vm-images'],
	}
	

    # Disable 'default' network
	# run this only if 'default' is already started  
	exec { "Disable_default_network" :
			   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
			command => "virsh net-destroy default",
			 onlyif => 'virsh net-list | grep default',
	}
    
    
}
