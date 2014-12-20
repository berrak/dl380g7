##
## This class manage iptables and fail2ban
##
class hp_iptables_fail2ban::install {

    
    if ! ( $::operatingsystem == 'Debian' ) {
        fail("FAIL: Aborting. This module is only for Debian based distributions!")
    }
    
    package  { 'iptables' :
                ensure => installed }

    package { 'fail2ban':
                 ensure => installed,
                require => Package['iptables'],
    }

}
