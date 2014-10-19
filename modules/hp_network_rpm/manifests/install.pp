#
# Manage network
#
class hp_network_rpm::install {

    # do NOT install NM on a headless server and with virtual guests
    package { "NetworkManager" :
               ensure => purged,
        allow_virtual => true,
    }

    # provides uuidgen
    package { "util-linux-ng" : ensure => installed }

}