#
# Manage apache2
#
class hp_apache2 {

    include hp_apache2::install, hp_apache2::config, hp_apache2::service

}