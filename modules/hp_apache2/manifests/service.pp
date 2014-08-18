#
# Manage apache2
#
class hp_apache2::service {

    service { "apache2":
        enable => true,
        ensure => running,
        require => Package[apache2-mpm-prefork],
    }
    
}