##
## This class manage the ntp service, with 
## one host acting as the local lan time sever.
##
##
## Sample usage:
##
##   class { 'hp_ntp' : role => 'lanclient', peerntpip => $ipaddress }
##   class { 'hp_ntp' : role => 'lanserver', peerntpip => '192.168.0.1' }
##
class hp_ntp(
    $role='lanclient',
    $peerntpip='UNSET',
) {
        
    package { "ntp" : ensure => present }
    
    case $role {

        lanclient:  {
                    
            file { "ntp.conf.lanclient":
                path => "/etc/ntp.conf",
                source => "hp:///modules/hp_ntp/ntp.conf.lanclient",
                owner => "root",
                group => "root",
                require => Package["ntp"],
                notify => Service["ntp"],
            }
            
            service { "ntp":
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
                source => "hp:///modules/hp_ntp/ntp.conf.lanserver",
                owner => "root",
                group => "root",
                require => Package["ntp"],
                notify => Service["ntp"],
            }
            
            
            service { "ntp":
                ensure => running,
                hasstatus => true,
                hasrestart => true,
                enable => true,
                require => File["ntp.conf.lanserver"],

            }
            
        }

        default:  {
            fail( "Unknown parameter ($role) to $module_name" )
        }
            
    }
    
    # Practical time and status script
    
    if $peerntpip == 'UNSET' {
        fail("$module_name: The ip address is not defined.")
    } else {
    
        $local_ntpserver = $peerntpip
        
        file { '/root/bin/ntp.time' :
            content =>  template( 'hp_ntp/ntp.time.erb' ),
               mode => '0700',
              owner => 'root',
              group => 'root',
            require => Package["ntp"], 
        }
    }
    

}