#
# Manage fail2ban
#
class hp_iptables_fail2ban::service {

    service { 'fail2ban':
        enable => true,
        ensure => running,
        require => Package['fail2ban'],
    }
    
}