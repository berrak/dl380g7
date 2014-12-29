#
# Manage apache2
#
class hp_apache2_deb {

    include hp_apache2_deb::install, hp_apache2_deb::config, hp_apache2_deb::service

}
