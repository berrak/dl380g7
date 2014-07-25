##
## This class manage iptables and fail2ban
##
class hp_iptables_fail2ban {

    include hp_iptables_fail2ban::install, hp_iptables_fail2ban::config,
            hp_iptables_fail2ban::service
	
}
