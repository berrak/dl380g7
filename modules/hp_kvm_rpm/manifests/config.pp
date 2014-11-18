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
  
    # helper perl script to create guests
	file { '/root/bin/create-guest.pl' :
		source => "puppet:///modules/hp_kvm_rpm/create-guest.pl",
		 owner => 'root',
		 group => 'root',
	      mode => '0700',
	}
    
    # README to remember required steps when re-creating a guest with identical name
	file { '/etc/libvirt/qemu/README.re-run-virtualguest' :
		source => "puppet:///modules/hp_kvm_rpm/README.re-run-virtualguest",
		 owner => 'root',
		 group => 'root',
	}
    
}
