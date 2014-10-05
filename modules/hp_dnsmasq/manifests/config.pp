##
## This class manage DNS, resolv.conf and the 'hosts' file
##
class hp_dnsmasq::config ( $dns1='', $dns2='', $real_hostname='' ) {

    include hp_dnsmasq
    
    # template variables
    
    $mydns1 = $dns1
    $mydns2 = $dns2 
    
    $puppetsrvfqdn = $::fqdn
    $myhostname = $::hostname
    $myip = $::ipaddress
    $mydomain = $::domain

    if $myhostname == $real_hostname {

        file { '/etc/hosts' :
            content =>  template( "hp_dnsmasq/${real_hostname}_hosts.erb" ),    
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
        fail("FAIL: Hostname ${real_hostname} unknown. Aborting...")
    }

}
