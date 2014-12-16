##
## This class manage the ntp service, with 
## one host acting as the local lan time sever.
##
##
## Sample usage:
##
##   class { 'hp_ntp' : role => 'lanclient', local_ntp_srvip => '192.168.0.1',
##                      local_ntp_srvnet => '192.168.0.0', local_ntp_srvmask => '255.255.255.0' }
##   class { 'hp_ntp' : role => 'lanserver', local_ntp_srvip => '192.168.0.1',
##                      local_ntp_srvnet => '192.168.0.0', local_ntp_srvmask => '255.255.255.0' }
##
class hp_ntp ( $role , $local_ntp_srvip, $local_ntp_srvnet, $local_ntp_srvmask ) {
        
    package { "ntp" :
               ensure => present,
        allow_virtual => true,
    }
    
    $ostype = $::operatingsystem
    
    # Handle some differences between Debian and OracleLinux
    
    if $ostype == 'Debian' {
        $ntpservicename = 'ntp'
        $ntpqbinpath = '/usr/bin/ntpq' 
    }
    elsif $ostype == 'OracleLinux'  {
        $ntpservicename = 'ntpd'
        $ntpqbinpath = '/usr/sbin/ntpq' 
    } else {
    	fail("FAIL: Unknown $ostype distribution. Aborting...")
    }
    
    case $role {

        lanclient:  {
                    
            file { "ntp.conf.lanclient":
                path => "/etc/ntp.conf",
                content =>  template( "hp_ntp/ntp.conf.lanclient.erb" ),      
                owner => "root",
                group => "root",
                require => Package["ntp"],
                notify => Service["$ntpservicename"],
            }
            
            service { "$ntpservicename":
                ensure => running,
                hasstatus => true,
                hasrestart => true,
                enable => true,
                require => File["ntp.conf.lanclient"],

            }
               
        }
                    
        lanserver:  {
        
            file { "ntp.conf.lanserver":
                path => "/etc/ntp.conf",
                content =>  template( "hp_ntp/ntp.conf.lanserver.erb" ),   
                owner => "root",
                group => "root",
                require => Package["ntp"],
                notify => Service["$ntpservicename"],
            }
            
            
            service { "$ntpservicename":
                ensure => running,
                hasstatus => true,
                hasrestart => true,
                enable => true,
                require => File["ntp.conf.lanserver"],

            }
            
        }

        default:  {
            fail( "FAIL: Unknown parameter for role ($role)" )
        }
            
    }
    
    # Practical time and status test script
    $local_ntpserver = $local_ntp_srvip
    
    file { '/root/bin/ntp.time' :
        content =>  template( 'hp_ntp/ntp.time.erb' ),
           mode => '0700',
          owner => 'root',
          group => 'root',
        require => Package["ntp"], 
    }

}
