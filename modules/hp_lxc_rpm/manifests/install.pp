##
## This class manage LXC
##
class hp_kvm_rpm::install {

    if ! ( $::lsbdistid == 'OracleServer' ) {
        fail("FAIL: Aborting. This module (lxc) is only for OracleLinux based distributions!")
    }

    package { ["lxc", "libcgroup", "lxc-libs", "btrfs-progs" ] :
               ensure => present,
        allow_virtual => true,
    }

}
