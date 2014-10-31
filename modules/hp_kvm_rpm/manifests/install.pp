##
## This class manage KVM
##
class hp_kvm_rpm::install {

    package { ["kvm", "libvirt", "qemu-kvm", "bridge-utils", "fuse",
	           "libvirt-python", "python-virtinst", "libguestfs-tools" ] :
               ensure => present,
        allow_virtual => true,
    }

	# insert KVM-AMD kernel module unless already installed
	exec { 'Insert_kernel_module_kvm_amd':
		command => 'modprobe --first-time kvm-amd > /dev/null 2>&1',
		   path => '/sbin:/bin:/usr/sbin:/usr/bin',
		 unless => 'modprobe -l | grep --color kvm-amd > /dev/null',
	    require => Package["kvm"],
	}
	
	# insert KVM-Intel kernel module unless already installed
	exec { 'Insert_kernel_module_kvm_intel':
		command => 'modprobe --first-time kvm-intel > /dev/null 2>&1',
		   path => '/sbin:/bin:/usr/sbin:/usr/bin',
		 unless => 'modprobe -l | grep --color kvm-intel > /dev/null', 
	    require => Package["kvm"],
	}
	
	# add root to group fuse
    exec { "add_root_to_fuse_group" :
            command => "usermod -a -G fuse root",
               path => '/usr/bin:/usr/sbin:/bin',
             unless => "cat /etc/group | grep fuse | grep root",
	    require => Package["fuse"],
    }
	

}
