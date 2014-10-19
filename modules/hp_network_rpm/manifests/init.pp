#
# Manage networking
#
class hp_network_rpm {

    include hp_network_rpm::install, hp_network_rpm::config, hp_network_rpm::service

}