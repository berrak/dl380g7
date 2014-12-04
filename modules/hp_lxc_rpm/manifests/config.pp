##
## This class manage LXC
##
class hp_lxc_rpm::config {

	# default configuration for new container creation
	file { '/etc/lxc/default.conf' :
		source => "puppet:///modules/hp_lxc_rpm/default.conf",
		 owner => 'root',
		 group => 'root',
	}
	
	# create the directory for hooks scripts
	file { "/container/common-hooks":
		ensure => "directory",
		owner => 'root',
		group => 'root',
	}
	
	file { '/container/common-hooks/iptables-host-accept-containers.sh' :
		 source => "puppet:///modules/hp_lxc_rpm/iptables-host-accept-containers.sh",
		  owner => 'root',
		  group => 'root',
		   mode => '0755',
	    require => File["/container/common-hooks"],
	}
	
	
}
