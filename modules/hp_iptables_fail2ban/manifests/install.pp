##
## This class manage iptables and fail2ban
##
class hp_iptables_fail2ban::install {

    package  { 'iptables' :
                ensure => installed }

    package { 'fail2ban':
                 ensure => installed,
                require => Package['iptables'],
    }

}
