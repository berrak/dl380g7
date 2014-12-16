##
## This class manage DNS, resolv.conf and the 'hosts' file.
## The 'puppetmaster' name resolution is always set to "puppet.$srv_domain" in 'hosts'.
##
class hp_dnsmasq::config ( $ispdns1='', $ispdns2='', $srv_hostname='', $srv_domain='' ) {

    include hp_dnsmasq
     
    # template variables   
    $mydns1 = $ispdns1
    $mydns2 = $ispdns2 
    
    $myhostname = $srv_hostname
    $mydomain = $srv_domain
    
    $hostip = $::ipaddress

    if ( $srv_hostname in $::hp_dnsmasq::params::puppet_server_list ) {

        file { '/etc/hosts' :
            content =>  template( "hp_dnsmasq/${srv_hostname}_hosts.erb" ),    
              owner => 'root',
              group => 'root',
               mode => '0644',
        }
        
        file { '/etc/resolv.conf' :
            content =>  template( "hp_dnsmasq/resolv.conf.erb" ),    
              owner => 'root',
              group => 'root',
               mode => '0644',
        }
    
        file { '/etc/dnsmasq.conf' :
            content =>  template( "hp_dnsmasq/dnsmasq.conf.erb" ),    
              owner => 'root',
              group => 'root',
               mode => '0644',
             notify => Service["dnsmasq"],
        }        
        
        
    }
    else {
        fail("FAIL: Hostname ${srv_hostname} is not a puppetmaster!. Aborting...")
    }

}
