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
	
	# this will update any existing domain definition for the tpldeb-image (must exist) 
	file { "/etc/libvirt/qemu/$name.xml":
		content =>  template( "hp_kvm_rpm/tpldeb.xml.erb" ),
		  owner => 'root',
		  group => 'root',
		require => Class["hp_kvm_rpm"],
	} 
	
	# create the new guest
	exec { "Create_new_guest_$name" :
		       path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
		    command => "/root/bin/new-virtclone.sh $name",
	        require => File["/etc/libvirt/qemu/$name.xml"],
		refreshonly => 'true',
	}

}