#
# Manage network (add alias interface for virtual guest)
#
# Usage:
#      hp_network_rpm::alias { 'eth0:1' : publ_guest_ip => '192.168.0.42' }    
#
define hp_network_rpm::alias ( $publ_guest_ip='' ) {

    include hp_network_rpm
	
	$host_ip = $public_guest_ip
    $host_netmask = $::netmask
 
	file { "/etc/sysconfig/network-scripts/ifcfg-$alias_interface":
		content =>  template( "hp_network_rpm/ifcfg-$name.erb" ),
		  owner => 'root',
		  group => 'root',
		 notify => Service['network'],
	} 

}