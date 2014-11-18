#
# This define new a KVM guest on hypervisor OracleLinux 6.5
#
# Usage: hp_kvm_rpm::add_guest { 'debinix.org' :
#                local_guest_mac => '52:54:00:ff:ff:00',
#                local_guest_gw => '192.168.40.1',
#                local_guest_ip  => '192.168.40.2',
#                local_hostname  => 'deborg',
#                nat_bridge_name => 'bridge99',
#    }
#        
define hp_kvm_rpm::add_guest ( $local_guest_mac, $local_guest_gw, $local_guest_ip, $local_hostname, $nat_bridge_name ) {

    include hp_kvm_rpm
	
    if ! ( $::lsbdistid == 'OracleServer' ) {
        fail("FAIL: Aborting. This module (iptables) is only for OracleLinux based distributions!")
    }
	
	if ( $local_guest_mac == '' ) {
		fail("FAIL: Missing given virtual host mac address")
	}	
	
	if ( $local_guest_gw == '' ) {
		fail("FAIL: Missing given virtual host gateway IP address")
	}
	
	if ( $local_guest_ip == '' ) {
		fail("FAIL: Missing given virtual host local IP address")
	}
		
	if ( $local_hostname == '' ) {
		fail("FAIL: Missing given virtual host name")
	}
	
	if ( $nat_bridge_name == '' ) {
		fail("FAIL: Missing given bridge name")
	}	
	
	# add new network for this guest and start it
	file { "/etc/libvirt/qemu/networks/$name.xml":
		content =>  template( "hp_kvm_rpm/$name.erb" ),
		  owner => 'root',
		  group => 'root',
		   mode => '0600',
	} 
	exec { "Create_new_network_$name" :
		       path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
		    command => "virsh net-define /etc/libvirt/qemu/networks/$name.xml && virsh net-start $name && virsh net-autostart $name",
		refreshonly => 'true',
		  subscribe => File["/etc/libvirt/qemu/networks/$name.xml"],
	}
	
					
	# create the new guest (from '/var/lib/libvirt/images/tpldeb.img', must exist) 
	exec { "Create_new_guest_$name" :
		   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
		command => "/root/bin/create-guest.pl $name $local_guest_mac $local_guest_ip $local_hostname $nat_bridge_name",
		 unless => "ls /var/lib/libvirt/images/ | grep $name",
		require => File["/etc/libvirt/qemu/networks/$name.xml"],
	}

}