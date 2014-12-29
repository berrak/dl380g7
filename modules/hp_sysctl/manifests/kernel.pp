##
## Hardening a host.
##
class hp_sysctl::kernel {

    $mydomain = $::domain
	
	if ( $::operatingsystem == 'Debian' ) {

		file { "/etc/sysctl.conf":
			content =>  template( 'hp_sysctl/sysctl.conf.deb.erb' ),     
			  owner => 'root',
			  group => 'root',
			 notify => Exec["UPDATING_DEB_KERNEL_SYSCTL_CONFIGURATION"],
		}   
	 
		exec { "UPDATING_DEB_KERNEL_SYSCTL_CONFIGURATION" :
				command => "/sbin/sysctl -p",
			refreshonly => true,
		}
		
	} elsif ( $::operatingsystem == 'OracleLinux' ) {
	
		file { "/etc/sysctl.conf":
            source => "puppet:///modules/hp_sysctl/sysctl.conf-rpm",				 
			  owner => 'root',
			  group => 'root',
			 notify => Exec["UPDATING_RPM_KERNEL_SYSCTL_CONFIGURATION"],
		}   
	 
		exec { "UPDATING_RPM_KERNEL_SYSCTL_CONFIGURATION" :
				command => "/sbin/sysctl -p",
			refreshonly => true,
		}
	
	} else {
	
		fail("FAIL: Unknown operatingsystem ($::operatingsystem). Aborting...")
	
	}
    
}
