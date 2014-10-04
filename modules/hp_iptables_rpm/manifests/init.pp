##
## This class manage iptables
##
class hp_iptables_rpm {

    include hp_iptables_rpm::install, hp_iptables_rpm::config,
            hp_iptables_rpm::service
	
}
