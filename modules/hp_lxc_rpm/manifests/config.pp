##
## This class manage LXC
##
class hp_lxc_rpm::config {

	# default configuration for new container creation
	file { '/etc/lxc/default.conf' :
		source => "puppet:///modules/hp_kvm_rpm/default.conf",
		 owner => 'root',
		 group => 'root',
	}
	
}
