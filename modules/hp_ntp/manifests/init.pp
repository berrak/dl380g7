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
        
    package { "ntp" :
               ensure => present,
        allow_virtual => true,
    }
    
    $ostype = $::operatingsystem
    
    # Handle some differences between Debian and OracleLinux(OracleLinux)
    
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
                source => "puppet:///modules/hp_ntp/ntp.conf.lanclient",
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
                source => "puppet:///modules/hp_ntp/ntp.conf.lanserver",
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
            fail( "Unknown parameter ($role) to $module_name" )
        }
            
    }
    
    # Enable ntpd at boot
    if $ostype == 'OracleLinux'  {
        
        exec { 'Enable_OL6_ntpd_at_boot':
		command => '/sbin/chkconfig ntpd on',
		 path   => '/usr/bin:/usr/sbin:/bin:/sbin',
		require => Package['ntp'],
         onlyif => "chkconfig | grep 'ntpd ' | grep 3:off",
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
