##
## This class manage KVM
##
class hp_kvm_deb::install {

    package { ["qemu-kvm", "libvirt-bin", "virtinst" ] :
               ensure => present,
        allow_virtual => true,
    }

}
