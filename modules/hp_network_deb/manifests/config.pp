#
# Manage network
#
# Usage: hp_network_deb::config { 'kvmbr0'  :
#            ip => '192.168.0.66',
#            netmask => '255.255.255.0',
#			 network => '192.168.0.0',
#            enlaved_if => 'eth0'
#            gateway => '192.168.0.1',
#            broadcast => '192.168.0.255',
#        }
#
define hp_network_deb::config ( $ip, $netmask, $network, $enlaved_if, $gateway, $broadcast ) {

	include hp_network_deb::install, hp_network_deb::service
	
	if ( $ip == '' ) {
		fail("FAIL: Missing given host IP address")
	}
	
	$host_interface = $name
	$host_address = $ip
    $host_netmask = $netmask
    $host_network = $network	
	$host_gateway = $gateway
	$host_broadcast = $broadcast
	
	$host_enslaved_interface = $enlaved_if


	# configure normal interface (eth0 or eth1) or bridge
    if ( enlaved_if == '' ) {
	
		file { "/etc/network/interfaces":
			content =>  template( "hp_network_deb/$name.interfaces.erb" ),
			  owner => 'root',
			  group => 'root',
			 notify => Service['networking'],
			require => Package['bridge-utils'],
		}
			 
	} else {
	
		file { "/etc/network/interfaces":
			content =>  template( "hp_network_deb/$name.interfaces.erb" ),
			  owner => 'root',
			  group => 'root',
			 notify => Service['networking'],
			require => Package['bridge-utils'],
		}
	}
	
}
