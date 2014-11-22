##
## This class manage KVM
##
class hp_kvm_rpm::service {
    	
	service { "libvirtd" :
			ensure => running,
			enable => true,
		   require => Package["libvirt"],
		    notify => Exec["Enable_default_network"],
	}
	
	exec { "Enable_default_network" :
		       path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
		    command => "virsh net-start default && virsh net-autostart default",
		  subscribe => Service["libvirtd"],
	}	
	
}