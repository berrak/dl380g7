##
## This class manage KVM
##
class hp_kvm_rpm::config {

    include hp_kvm_rpm

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
    
    # re-create default NAT subnet 122 network - unless 'default' network does not exist
 	exec { "Create_default_network" :
		       path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
		    command => "virsh net-define /usr/share/libvirt/networks/default.xml",
		     unless => 'ls /etc/libvirt/qemu/networks | grep default',
	}	   
    
    # Enable or Disable 'default' network
    if ( $natnet_default_active == 'true' ) {
        # when enabled, run this unless 'default' is already started  
        exec { "Enable_default_network" :
                   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
                command => "virsh net-start default && virsh net-autostart default",
                 unless => 'virsh net-list | grep default',
                 require => Exec["Create_default_network"],
        }
    } else {
        # when enabled, run this only if 'default' is already started  
        exec { "Disable_default_network" :
                   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
                command => "virsh net-destroy default",
                 onlyif => 'virsh net-list | grep default',
                 require => Exec["Create_default_network"],
        }
    
    }
}
