##
## Class to manage SELinux
##
## Sample usage:
##		hp_selinux::state { 'enforcing' : }
##		hp_selinux::state { 'permissive' : }
##		hp_selinux::state { 'disabled' : }
##
define hp_selinux::state {
    
	include hp_selinux
	
    if $name == '' {
        fail("FAIL: SELINUX wanted state not given! Aborting...")
    }
	
	if ! ( $name in [ 'enforcing', 'permissive', 'disabled' ] ) {
        fail("FAIL: SELINUX unknown state given! Aborting...")	
	}
    
	$ostype = $::operatingsystem
	
	if $ostype == 'OracleLinux' {
	
        file { "/etc/selinux/config":
            content =>  template( "hp_selinux/config.erb" ),
              owner => 'root',
              group => 'root',
               mode => '0644',
        }
		
		# need to reboot after any config changes
		exec { 'REBOOTING_SYSTEM_DUE_TO_CHANGES_IN_SELINUX_CONFIG':
			    command => 'reboot',
			       path => '/bin:/sbin:/usr/bin:/usr/sbin',
			  subscribe => File['/etc/selinux/config'],
			refreshonly => true,
		}	
		
        
	} else {
		fail("FAIL: SELINUX on unsupported ($ostype) distribution. Aborting...")
	}
    
}
    
    
