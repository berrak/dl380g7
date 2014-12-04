#
# Manage apache2 (RPM version)
#
class hp_apache2_rpm {

    include hp_apache2_rpm::install, hp_apache2_rpm::config, hp_apache2_rpm::service

}