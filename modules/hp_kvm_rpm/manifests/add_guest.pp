#
# This define new a KVM guest on hypervisor OracleLinux 6.5
#
# Usage: hp_kvm_rpm::add_guest { 'debinix' :
#                local_guest_ip  => '192.168.221.43',
#                local_guest_mac => '52:54:00:ff:ff:43',
#                uuid => '337dcb1e-6e79-4f2d-b0d5-6f255b961e94',
#    }
#        
define hp_kvm_rpm::add_guest ( $local_guest_ip, $local_guest_mac, $uuid ) {

    include hp_kvm_rpm
	
    if ! ( $::lsbdistid == 'OracleServer' ) {
        fail("FAIL: Aborting. This module (iptables) is only for OracleLinux based distributions!")
    }
	
	if ( $local_guest_ip == '' ) {
		fail("FAIL: Missing given virtual host local IP address")
	}
			
	# create the new guest ('/var/lib/libvirt/images/tpldeb.img' must exist) 
	exec { "Create_new_guest_$name" :
		       path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
		    command => "/root/bin/create-guest.pl $name",
	      require => Class["hp_kvm_rpm"],
			 unless => "ls /virtimages/ | grep $name",
	}

}