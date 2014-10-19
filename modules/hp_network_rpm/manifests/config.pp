#
# Manage network
#
class hp_network_rpm::config ( $interface='', $ip='', $prefix='', 
                $gateway='', $broadcast='', $ispdns1='', $ispdns2='', ) {

	include hp_network_rpm
	
	if ( $ip == '' ) {
		fail("FAIL: Missing given host IP address")
	}
	
	$host_interface = $interface

	$host-ip = $ip
    $host-prefix = $prefix
	$host-gateway = $gateway
	$host-broadcast = $broadcast,
	$host-dns1 = $ispdns1
	$host-dns2 = $ispdns2	

	$host-mac = $::macaddress_${interface}
	$host-domain = $::domain
	
	file { "/etc/sysconfig/network-scripts/ifcfg-${interface}":
		content =>  template( "hp_network_rpm/ifcfg-${interface}.erb" ),
		  owner => 'root',
		  group => 'root',
		 notify => Service['network'],
	} 
    
}