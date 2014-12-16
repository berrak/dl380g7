##
## NOTE: This class manage hosts file on puppet-agents only
## (not puppetservers -- use dnsmasq module for hosts file)
## 
class hp_hosts::config ( $srv_hostname, $srv_domain, $srv_host_ip ) {

    # template variables for node
    $myhostname = $::hostname
    $myip = $::ipaddress
    $mydomain = $::domain

    # this is for only for puppet agents nodes!
    if $myhostname != $srv_hostname {

        file { '/etc/hosts' :
            content =>  template( "hp_hosts/$puppet_hosts.erb" ),    
              owner => 'root',
              group => 'root',
               mode => '0644',
        }
        
    }
    else {
        fail("FAIL: This host ($srv_hostname) is not a a puppet node. Aborting...")
    }

}
