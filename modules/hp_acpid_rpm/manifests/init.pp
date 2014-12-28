#
# Ensure acpid is instaled on minimal OracleLinux-6
# (otherwise 'virsh shutdown <guest>' does not work)
#
class hp_acpid_rpm {

    include hp_acpid_rpm::install, hp_acpid_rpm::config, hp_acpid_rpm::service

}
