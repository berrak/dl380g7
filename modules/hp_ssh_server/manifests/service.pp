##
## Puppet manage openssh server
##
class hp_ssh_server::service {
    
	
	if $ostype == 'Debian' {
		$sshservicename = 'ssh'
	} elsif $ostype == 'OracleServer' {
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