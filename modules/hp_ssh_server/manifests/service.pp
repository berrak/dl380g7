##
## Puppet manage openssh server
##
class hp_ssh_server::service {
    
	# this facter variable works in VMs and in LXC containers
	$ostype = $::operatingsystem
	
	if $ostype == 'Debian' {
		$sshservicename = 'ssh'
	} elsif $ostype == 'OracleLinux' {
		$sshservicename = 'sshd'
	} else {
		fail("FAIL: Unknown $ostype distribution. Aborting...")
	}	
	
	service { $sshservicename :
			ensure => running,
		 hasstatus => true,
		hasrestart => true,
			enable => true,
		   require => Package["openssh-server"],
	}
	
}