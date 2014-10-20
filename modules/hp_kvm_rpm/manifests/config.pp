##
## This class manage KVM
##
class hp_kvm_rpm::config {

	# qemu configuration - enable mac filtering for virtual guests
	file { '/etc/libvirt/qemu.conf' :
		source => "puppet:///modules/hp_kvm_rpm/qemu.conf",
		 owner => 'root',
		 group => 'root',
	   require => Package['libvirt'],
	    notify => Service['libvirtd'],
	}
 
}
