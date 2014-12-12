##
## This class manage KVM
##
class hp_kvm_deb::install {

    package { ["qemu-kvm", "libvirt-bin", "virtinst", "libguestfs-tools",
	           "liblog-log4perl-perl", "libxml-twig-perl" ] :
               ensure => present,
        allow_virtual => true,
    }

}
