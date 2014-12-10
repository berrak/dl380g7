#
# Manage network
#
class hp_network_deb::install {


    # configure network bridge
    package { "bridge-utils" :
               ensure => installed,
        allow_virtual => true,
    }

    # do NOT install on a headless server and with virtual guests
    package { "network-manager" :
               ensure => purged,
        allow_virtual => true,
    }

}