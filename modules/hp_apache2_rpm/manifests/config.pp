#
# Manage apache2 (RPM version)
#
class hp_apache2_rpm::config {

    $myipaddress = $::ipaddress
    $myhostname = $::hostname
    $mydomain = $::domain

    # apache2 main configuration file
    file { "/etc/httpd/conf/httpd.conf" :
        content =>  template( "hp_apache2_rpm/httpd.conf.erb" ),    
          owner => 'root',
          group => 'root',
           mode => '0644',
         notify => Service["httpd"],
    }
    
}