#
# Manage apache2 (RPM version)
#
class hp_apache2_rpm::service {

    service { "httpd":
        enable => true,
        ensure => running,
        require => Package["httpd"],
    }
    
}