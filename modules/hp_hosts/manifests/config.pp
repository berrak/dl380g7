##
## This class manage hosts
## 
class hp_hosts::config ( $puppetserver_hostname = '' ) {

    # template variables
    $puppetsrvfqdn = $::fqdn
    $myhostname = $::hostname
    $myip_eth0 = $::ipaddress_eth0
    $mydomain = $::domain

    if $myhostname == $puppetserver_hostname {

        file { '/etc/hosts' :
            content =>  template( "hp_hosts/${puppetserver_hostname}_hosts.erb" ),    
              owner => 'root',
              group => 'root',
               mode => '0644',
        }
        
    }
    else {
        fail("FAIL: Hostname ${puppetserver_hostname} unknown. Aborting...")
    }

}
