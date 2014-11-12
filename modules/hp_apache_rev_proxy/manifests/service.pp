#
# Manage apache2 reverse proxy for NAT VM's
#
class hp_apache_rev_proxy::service {

    service { "httpd":
        enable => true,
        ensure => running,
        require => Package["httpd"],
    }
    
}