#
# Manage apache2
#
class hp_apache2::install {

    package { "apache2-mpm-prefork" : ensure => installed }
    
    # Requires mod_headers to be enabled (see security)
    exec { "mod_header_install" :
           path => '/bin:/sbin:/usr/bin:/usr/sbin',
        command => 'a2enmod mod_headers',
         unless =>  '/etc/apache2/mods-enabled/headers.load',
        require => Package ["apache2-mpm-prefork"],
    }
    
}