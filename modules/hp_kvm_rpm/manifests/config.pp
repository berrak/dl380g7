##
## This class manage KVM
##
class hp_kvm_rpm::config {

	# qemu configuration - enable mac filtering for virtual guests
	file { '/etc/libvirt/qemu.conf' :
		source => "puppet:///modules/hp_kvm_rpm/qemu.conf",
		 owner => 'root',
		 group => 'root',
	   require => Package['libvirt'],
	    notify => Service['libvirtd'],
	}
  
    # new main helper perl script to create guests
	file { '/root/bin/create-guest.pl' :
		source => "puppet:///modules/hp_kvm_rpm/create-guest.pl",
		 owner => 'root',
		 group => 'root',
	      mode => '0700',
	}
    
#    # helper perl script to set uuid of new guests
#	file { '/root/bin/create-uuid-in-xml.pl' :
#		source => "puppet:///modules/hp_kvm_rpm/create-uuid-in-xml.pl",
#		 owner => 'root',
#		 group => 'root',
#	      mode => '0755',
#	}
#    
#    # helper shell script to automate new guest creation
#	file { '/root/bin/new-virtclone.sh' :
#		source => "puppet:///modules/hp_kvm_rpm/new-virtclone.sh",
#		 owner => 'root',
#		 group => 'root',
#	      mode => '0755',
#	}
    
 
}
