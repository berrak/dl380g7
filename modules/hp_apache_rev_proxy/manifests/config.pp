#
# Manage apache2 reverse proxy for NAT VM's
#
class hp_apache_rev_proxy::config {

    # apache2 main configuration file
    file { "/etc/httpd/conf/httpd.conf" :
        content =>  template( "hp_apache_rev_proxy/httpd.conf.erb" ),    
          owner => 'root',
          group => 'root',
           mode => '0644',
         notify => Service["httpd"],
    }
    
}