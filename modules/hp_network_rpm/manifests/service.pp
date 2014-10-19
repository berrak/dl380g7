#
# Manage network
#
class hp_network_rpm::service {

    service { "network":
        enable => true,
        ensure => running,
    }
    
}