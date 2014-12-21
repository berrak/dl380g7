#
# This define new a KVM guest on hypervisor Debian Wheezy
#
# Usage: hp_kvm_deb::add_guest { 'trise' :
#                    local_guest_gw => '192.168.0.1',
#                   local_guest_ip  => '192.168.0.41',
#                 local_mac_address => '52:54:00:00:00:41', 
#                  local_guest_bcst => '192.168.0.255',
#                  local_guest_netw => '192.168.0.0',
#                   local_hostname  => 'trise',
#                       bridge_name => 'kvmbr0',
#                        auto_start => 'true',
#    }
#        
define hp_kvm_deb::add_guest ( $local_guest_gw, $local_guest_ip, $local_mac_address, $local_guest_bcst, $local_guest_netw, $local_hostname, $bridge_name, $auto_start ) {

    
	if ( $::operatingsystem != 'Debian' ) {
        fail("FAIL: Aborting. This module (add_guest) is only for Debian based hosts!")
    }
	
	include hp_kvm_deb
	
	if ( $local_guest_ip == '' ) {
		fail("FAIL: Missing given virtual host IP address!")
	}
	
	# domain name used by virsh/libvirt
	$guest_name = $name 
	

	# create the guest configuration
	file { "/etc/libvirt/qemu/$guest_name.xml":
		content =>  template( "hp_kvm_deb/$guest_name.xml.erb" ),
		  owner => 'root',
		  group => 'root',
		   mode => '0600',
		require => File['/root/bin/create-deb-guest.pl'],
	}	
		
	# create the new guest (from '/data/vm-images/wheezy.img', must exist) 
	exec { "Create_new_guest_$guest_name" :
		   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
		command => "/root/bin/create-deb-guest.pl $guest_name $local_guest_gw $local_guest_ip $local_mac_address $local_guest_bcst $local_guest_netw $local_hostname $bridge_name",
		 unless => "ls /data/vm-images/ | grep $guest_name",
		require => File["/etc/libvirt/qemu/$guest_name.xml"],
	}
	
	if ( $auto_start == 'true') {
	
		# create a link does the virsh autostart magic
		file { "/etc/libvirt/qemu/autostart/${guest_name}.xml":
			ensure => present,
			target => "/etc/libvirt/qemu/${guest_name}.xml",
			require => File["/etc/libvirt/qemu/$guest_name.xml"],
		}
	
	
	}
	
	

}
