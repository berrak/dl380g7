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
	
	# helper script to create distribution specific kvm base images to clone new guest from
	file { "/root/bin/create-kvm-box.pl":
		content =>  template( "hp_kvm_deb/create-kvm-box.pl.erb" ),
		  owner => 'root',
		  group => 'root',
		   mode => '0700',
	}		
	
    # helper perl script to create guests from Debian based images
	file { '/root/bin/create-deb-guest.pl' :
		source => "puppet:///modules/hp_kvm_deb/create-deb-guest.pl",
		 owner => 'root',
		 group => 'root',
	      mode => '0700',
	}
	
    # helper perl script to create guests from OracleLinux 6 based images
	file { '/root/bin/create-oracle-guest.pl' :
		source => "puppet:///modules/hp_kvm_deb/create-oracle-guest.pl",
		 owner => 'root',
		 group => 'root',
	      mode => '0700',
	}	
	
	
	
}
