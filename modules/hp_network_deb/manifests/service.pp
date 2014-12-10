#
# Manage network
#
class hp_network_deb::service {

    service { "networking":
        enable => true,
        ensure => running,
    }
    
}