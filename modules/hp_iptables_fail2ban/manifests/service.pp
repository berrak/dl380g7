#
# Manage fail2ban
#
class hp_iptables_fail2ban::service {

    include hp_iptables_fail2ban::install
    
    service { 'fail2ban':
        enable => true,
        ensure => running,
        require => Package['fail2ban'],
    }
    
}
