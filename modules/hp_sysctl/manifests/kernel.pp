##
## Hardening a host.
##
class hp_sysctl::kernel {

    $mydomain = $::domain

    file { "/etc/sysctl.conf":
        content =>  template( 'hp_sysctl/sysctl.conf.erb' ),     
          owner => 'root',
          group => 'root',
           mode => '0644',
		 notify => Exec["UPDATING_KERNEL_SYSCTL_CONFIGURATION"],
    }   
 
	exec { "UPDATING_KERNEL_SYSCTL_CONFIGURATION" :
		    command => "/sbin/sysctl -p",
		refreshonly => true,
	}   
    
}