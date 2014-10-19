#
# Manage network
#
class hp_network_rpm::config ( $interface='', $ip='', $prefix='', 
                $gateway='', $broadcast='', $ispdns1='', $ispdns2='' ) {

	include hp_network_rpm
	
	if ( $ip == '' ) {
		fail("FAIL: Missing given host IP address")
	}
	
	$host_interface = $interface

	$host_ip = $ip
    $host_prefix = $prefix
	$host_gateway = $gateway
	$host_broadcast = $broadcast
	$host_dns1 = $ispdns1
	$host_dns2 = $ispdns2	

	$host_mac = $::macaddress
	$host_domain = $::domain
	
	file { "/etc/sysconfig/network-scripts/ifcfg-$interface":
		content =>  template( "hp_network_rpm/ifcfg-$interface.erb" ),
		  owner => 'root',
		  group => 'root',
		 notify => Service['network'],
	} 
    
}