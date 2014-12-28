#
# Ensure acpid is instaled on minimal OracleLinux-6
# (otherwise 'virsh shutdown <guest>' does not work)
#
class hp_acpid_rpm::service {

	include hp_acpid_rpm::install

    service { 'acpid':
        enable => true,
        ensure => running,
        require => Package['acpid'],
    }

}
