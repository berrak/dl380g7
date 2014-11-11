##
## This class manage DNS
##
class hp_bind_rpm {

    include hp_bind_rpm::install, hp_bind_rpm::config, hp_bind_rpm::service

}
