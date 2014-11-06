#
# This define new a KVM guest on hypervisor OracleLinux 6.5
#
# Usage: hp_kvm_rpm::add_guest { 'debinix_org' :
#                local_guest_mac => '52:54:00:ff:ff:43',
#                local_guest_ip  => '192.168.221.43',
#                local_hostname  => 'deborg', 
#    }
#        
define hp_kvm_rpm::add_guest ( $local_guest_mac, $local_guest_ip, $local_hostname ) {

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
	
	if ( $local_hostname == '' ) {
		fail("FAIL: Missing given virtual host name")
	}	
					
	# create the new guest (from '/var/lib/libvirt/images/tpldeb.img', must exist) 
	exec { "Create_new_guest_$name" :
		   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
		command => "/root/bin/create-guest.pl $name $local_guest_mac $local_guest_ip $local_hostname",
		 unless => "ls /var/lib/libvirt/images/ | grep $name",
	}

}