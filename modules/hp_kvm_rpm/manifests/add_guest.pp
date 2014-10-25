#
# This define new a KVM guest on hypervisor OracleLinux 6.5
#
# Usage: hp_kvm_rpm::add_guest { 'debinix' :
#                local_guest_ip  => '192.168.221.43',
#                local_guest_mac => '52:54:00:ff:ff:43',                
#    }
#        
define hp_kvm_rpm::add_guest ( $local_guest_ip, $local_guest_mac ) {

    include hp_kvm_rpm
	
    if ! ( $::lsbdistid == 'OracleServer' ) {
        fail("FAIL: Aborting. This module (iptables) is only for OracleLinux based distributions!")
    }
	
	if ( $local_guest_ip == '' ) {
		fail("FAIL: Missing given virtual host local IP address")
	}
	
	# remove any possible pre-existing definition
	exec { "Undefine_guest_$name":
		   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
		command => "virsh undefine $name",
		 unless => "ls /virtimages | grep $name",
	    require => Class["hp_kvm_rpm"],	
	}
	
	
	# this creates the domain definition
	file { "/etc/libvirt/qemu/$name.xml":
		content =>  template( "hp_kvm_rpm/tpldeb.xml.erb" ),
		  owner => 'root',
		  group => 'root',
		   mode => '0600',
		require => Exec["Undefine_guest_$name"],
		 notify => Exec["Create_new_guest_$name"],
	} 
	

	# create the new guest script ('/var/lib/libvirt/images/tpldeb.img' must exist) 
	exec { "Create_new_guest_$name" :
		       path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
		    command => "/root/bin/create-guest.pl $name",
		refreshonly => 'true',
	        require => Exec["/etc/libvirt/qemu/$name.xml"],
	}

}