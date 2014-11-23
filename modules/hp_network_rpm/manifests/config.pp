#
# Manage network
#
# Usage: hp_network_rpm::config { 'eth0'  :
#            ip => '192.168.0.66',
#            prefix => '24',
#            uuid => '8f83faf4-4ac3-4211-8616-1a87c6244039',
#            gateway => '192.168.0.1',
#            broadcast => '192.168.0.255',
#            ispdns1 => '195.67.199.18',
#            ispdns2 => '195.67.199.19',
#        }
#
define hp_network_rpm::config ( $ip, $prefix, $uuid,
                $gateway, $broadcast, $ispdns1, $ispdns2 ) {

	include hp_network_rpm
	
	if ( $ip == '' ) {
		fail("FAIL: Missing given host IP address")
	}
	
	$host_interface = $name

	$host_ip = $ip
    $host_prefix = $prefix
	$host_gateway = $gateway
	$host_broadcast = $broadcast
	$host_dns1 = $ispdns1
	$host_dns2 = $ispdns2	

	$host_mac = $::macaddress
	$host_domain = $::domain
	
	$host_uuid_interface = $uuid
	
	file { "/etc/sysconfig/network-scripts/ifcfg-$name":
		content =>  template( "hp_network_rpm/ifcfg-$name.erb" ),
		  owner => 'root',
		  group => 'root',
		 notify => Service['network'],
	} 
    
}