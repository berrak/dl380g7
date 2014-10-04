#
# Manage iptables
#
class hp_iptables_rpm::service {

	include hp_iptables_rpm::install

    service { 'iptables':
        enable => true,
        ensure => running,
        require => Package['iptables'],
    }
    
}