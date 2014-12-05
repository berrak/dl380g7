##
## This class manage resolv.conf in LXC
## 
class hp_lxc_resolvconf_rpm::config ( $lxcdomain, $dns1 , $dns2 , $dns3 ) {

    # explicit set nameserver and domain in resolv.conf
	file { "/etc/resolv.conf":
		content =>  template( "hp_lxc_resolvconf_rpm/resolv.conf.erb" ),
		  owner => 'root',
		  group => 'root',
	}

}
