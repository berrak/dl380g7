##
## This class manage iptables and fail2ban
##
class hp_iptables_fail2ban::install {

    package  { 'iptables' :
                   ensure => installed,
            allow_virtual => true,
    }

    package { 'fail2ban':
                   ensure => installed,
            allow_virtual => true,
                  require => Package['iptables'],
    }

}
