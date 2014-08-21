##
## Puppet manage openssh server
##
class hp_ssh_server::config {
    
    $myhostname = $::hostname	
	
	file { '/etc/ssh/sshd_config' :
           source => "puppet:///modules/hp_ssh_server/sshd_config.${myhostname}",		  
			owner => 'root',
			group => 'root',
		  require => Package["openssh-server"],
		   notify => Service["ssh"],
	}
	
	# our custom ssh login banner (warning for unathorized access)
	
	file { '/etc/issue.net' :
           source => "puppet:///modules/hp_ssh_server/issue.net",		  
			owner => 'root',
			group => 'root',
		  require => Package["openssh-server"],
	}		

}