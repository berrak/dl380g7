##
## This class manage DNS
##
class hp_bind_rpm::config ( $ispdns1='', $ispdns2='', $real_hostname='' ) {

    include hp_bind_rpm
    
    # template variables
    
    $mydns1 = $ispdns1
    $mydns2 = $ispdns2 
    
    $puppetsrvfqdn = $::fqdn
    $myhostname = $::hostname
    $hostip = $::ipaddress
    $mydomain = $::domain
    $myipaddress = $::ipaddress

    if $myhostname == $real_hostname {

        #file { '/etc/hosts' :
        #    content =>  template( "hp_bind_rpm/${real_hostname}_hosts.erb" ),    
        #      owner => 'root',
        #      group => 'root',
        #       mode => '0644',
        #}
        
        #file { '/etc/resolv.conf' :
        #    content =>  template( "hp_bind_rpm/resolv.conf.erb" ),    
        #      owner => 'root',
        #      group => 'root',
        #       mode => '0644',
        #}
    
        file { '/etc/named.conf' :
            content =>  template( "hp_bind_rpm/named.conf.erb" ),    
              owner => 'root',
              group => 'named',
               mode => '0640',
             notify => Service["named"],
        }
        
        $utime_serial = inline_template("<%= Time.now.to_i %>")        
        
        # create forward zone file
        file { "/var/named/$mydomain.db" :
            content =>  template( "hp_bind_rpm/$mydomain.db.erb" ),    
              owner => 'root',
              group => 'named',
               mode => '0640',
             notify => Service["named"],
        }
        
        # create reverse zone file
        file { "/var/named/$myhostname.$mydomain.db" :
            content =>  template( "hp_bind_rpm/$myhostname.$mydomain.db.erb" ),    
              owner => 'root',
              group => 'named',
               mode => '0640',
             notify => Service["named"],
        }     
        
    }
    else {
        fail("FAIL: Hostname ${real_hostname} unknown. Aborting...")
    }

}
