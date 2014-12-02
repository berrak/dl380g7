#
# Manage network (add alias interface for virtual guest)
#
# Usage:
#      hp_network_rpm::alias { 'eth0:1' : public_guest_ip => '192.168.0.42', prefix => '24', onboot => 'yes' }    
#
define hp_network_rpm::alias ( $public_guest_ip, $prefix, $onboot ) {

    include hp_network_rpm
	
	if ( $public_guest_ip == '' ) {
		fail("FAIL: Missing given virtual host public IP address")
	}
	
    $ip_prefix = $prefix
	$alias_interface = $name
	$onboot_if = $onboot
 
	file { "/etc/sysconfig/network-scripts/ifcfg-$alias_interface":
		content =>  template( "hp_network_rpm/ifcfg-$alias_interface.erb" ),
		  owner => 'root',
		  group => 'root',
		 notify => Service['network'],
		require => Class["hp_network_rpm"],
	} 

}