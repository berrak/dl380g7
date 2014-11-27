#
# This define new a KVM guest on hypervisor OracleLinux 6.5
#
# Usage: hp_kvm_rpm::add_guest { 'debinixorg' :
#                 local_guest_gw => '192.168.40.1',
#                local_guest_ip  => '192.168.40.2',
#                local_hostname  => 'deborg',
#                    bridge_name => 'bridge1',
#                 routed_network => '',
#                     guest_uuid => '4a6e421b-d4aa-46d5-b484-c81b9e812f60',
#    }
#        
define hp_kvm_rpm::add_guest ( $local_guest_gw, $local_guest_ip, $local_hostname, $bridge_name, $routed_network, $guest_uuid ) {

    include hp_kvm_rpm
	
	$guest_name = $name 
	
    if ! ( $::lsbdistid == 'OracleServer' ) {
        fail("FAIL: Aborting. This module (iptables) is only for OracleLinux based distributions!")
    }
	
	if ( $local_guest_gw == '' ) {
		fail("FAIL: Missing given virtual host gateway IP address!")
	}
	
	if ( $local_guest_ip == '' ) {
		fail("FAIL: Missing given virtual host local IP address!")
	}
		
	if ( $local_hostname == '' ) {
		fail("FAIL: Missing given virtual host name!")
	}
	
	if ( $bridge_name == '' ) {
		fail("FAIL: Missing given bridge name!")
	}

	if ( $routed_network == '' ) {
		fail("FAIL: Missing network name!")
	}
	
	if ( $guest_uuid == '' ) {
		fail("FAIL: Missing guest UUID!")
	}	
	
	# create the guest configuration
	file { "/etc/libvirt/qemu/$guest_name.xml":
		content =>  template( "hp_kvm_rpm/$guest_name.xml.erb" ),
		  owner => 'root',
		  group => 'root',
		   mode => '0600',
	}	
		
	# create the new guest (from '/var/lib/libvirt/images/wheezy.img', must exist) 
	exec { "Create_new_guest_$guest_name" :
		   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
		command => "/root/bin/create-guest.pl $guest_name $local_guest_ip $local_hostname $bridge_name",
		 unless => "ls /var/lib/libvirt/images/ | grep $guest_name",
		require => File["/etc/libvirt/qemu/$guest_name.xml"],
	}

}