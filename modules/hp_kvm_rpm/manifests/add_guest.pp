#
# This define new a KVM guest on hypervisor OracleLinux 6.5
#
# Usage: hp_kvm_rpm::add_guest { 'debinix' :
#                local_guest_mac => '52:54:00:ff:ff:43',
#                local_guest_ip  => '192.168.221.43',
#    }
#        
define hp_kvm_rpm::add_guest ( $local_guest_mac, $local_guest_ip ) {

    include hp_kvm_rpm
	
    if ! ( $::lsbdistid == 'OracleServer' ) {
        fail("FAIL: Aborting. This module (iptables) is only for OracleLinux based distributions!")
    }
	
	if ( $local_guest_mac == '' ) {
		fail("FAIL: Missing given virtual host mac address")
	}	
	
	if ( $local_guest_ip == '' ) {
		fail("FAIL: Missing given virtual host local IP address")
	}
			
	# Modify domain configuration template before cloning
	file { '/etc/libvirt/qemu/tpldeb.xml' :
		content =>  template( "hp_kvm_rpm/tpldeb.xml.erb" ),    
		  owner => 'root',
		  group => 'root',
		   mode => '0600',
	}		
					
	# create the new guest (from '/var/lib/libvirt/images/tpldeb.img', must exist) 
	exec { "Create_new_guest_$name" :
		   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
		command => "/root/bin/create-guest.pl $name $local_guest_mac $local_guest_ip",
	    require => Class["hp_kvm_rpm"],
		 unless => "ls /var/lib/libvirt/images/ | grep $name",
	}

}