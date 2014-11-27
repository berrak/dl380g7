##
## This class manage KVM
##
class hp_kvm_rpm::config ( $natnet_default_active='',
                           $routednet_name='',
                           $routednet_active='',
                           $routed_br_name='',
                           $routed_host_if='',
                           $routed_uuid='' )
{

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
    
    if ( $natnet_default_active == 'true' ) {
        # when enabled, run this unless default is already started  
        exec { "Enable_default_network" :
                   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
                command => "virsh net-start default && virsh net-autostart default",
                 unless => 'virsh net-list | grep default',
                 require => Exec["Create_default_network"],
        }
    }
    
	# create new ROUTED subnet 40 network
    if ( $routednet_active == 'true' ) {
        
        file { "/etc/libvirt/qemu/networks/$routednet_name.xml":
            content =>  template( "hp_kvm_rpm/$routednet_name.xml.erb" ),
              owner => 'root',
              group => 'root',
               mode => '0600',
        }
        
        # start network and make it persistent
        exec { "Create_new_network_$routednet_name" :
                   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
                command => "virsh net-define /etc/libvirt/qemu/networks/$routednet_name.xml && virsh net-start $routednet_name && virsh net-autostart $routednet_name",
            refreshonly => 'true',
              subscribe => File["/etc/libvirt/qemu/networks/$routednet_name.xml"],
                require => File["/etc/libvirt/qemu/networks/$routednet_name.xml"],
                 unless => "virsh net-list | grep $routednet_name",
        }
    }
    
}
