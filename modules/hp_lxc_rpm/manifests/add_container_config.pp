#
# This define configure the named system container (latest version of EL6)
# 
# Usage: hp_lxc_rpm::add_container_config { 'deborg' :
#            					cont_private_mac_addr => '52:54:00:00:00:40',
#                                cont_private_ip_addr => '192.168.122.40'
#}
#
# NOTE: Container must have been created with 'xlc-create' command first!
# NOTE: IP address is not used with dhcp, mac address and libvirt net 'default' defines container IP
#
define hp_lxc_rpm::add_container_config ( $cont_private_mac_addr, $cont_private_ip_addr ) {

    include hp_lxc_rpm
	
	$cont_host_name = $name 
	
    if ! ( $::lsbdistid == 'OracleServer' ) {
        fail("FAIL: Aborting. This module (hp_lxc_rpm) is only for OracleLinux based distributions!")
    }
	
	if ( $cont_private_mac_addr == '' ) {
		fail("FAIL: Missing given LXC container MAC address!")
	}
	
	if ( $cont_host_name == '' ) {
		fail("FAIL: Missing given LXC container name!")
	}
	
	# create the directory for the new container (needed for config file)
	file { "/container/$cont_host_name":
		ensure => "directory",
		owner => 'root',
		group => 'root',
	}	

	# create the container configuration
	file { "/container/$cont_host_name/config":
		content =>  template( "hp_lxc_rpm/$cont_host_name.config.erb" ),
		  owner => 'root',
		  group => 'root',
		  require => File["/container/$cont_host_name"],
	}
		
}