#
# Manage apache2
#
class hp_apache2::install {

    package { "apache2-mpm-prefork" : ensure => installed }

}