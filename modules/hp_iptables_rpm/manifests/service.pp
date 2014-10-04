#
# Manage iptables
#
class hp_iptables_rpm::service {

	include hp_iptables_rpm

    service { 'iptables':
        enable => true,
        ensure => running,
        require => Package['iptables'],
    }
    
}