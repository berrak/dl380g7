##
## Puppet manage openssh server
##
class hp_ssh_server::service {
    
	# for Debian
	service { 'ssh' :
			ensure => running,
		 hasstatus => true,
		hasrestart => true,
			enable => true,
		   require => Package["openssh-server"],
	}
	
	# for OracleLinux
	service { 'sshd' :
			ensure => running,
		 hasstatus => true,
		hasrestart => true,
			enable => true,
		   require => Package["openssh-server"],
	}
	
}