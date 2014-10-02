##
## Puppet manage openssh server
##
class hp_ssh_server::config {
    
    $myhostname = $::hostname	
	
	file { '/etc/ssh/sshd_config' :
           source => "puppet:///modules/hp_ssh_server/sshd_config",		  
			owner => 'root',
			group => 'root',
		  require => Package["openssh-server"],
		   notify => Service["ssh"],
	}
	
	# our custom ssh login banner (warning for unauthorized access)
	
	file { '/etc/issue.net' :
           source => "puppet:///modules/hp_ssh_server/issue.net",		  
			owner => 'root',
			group => 'root',
		  require => Package["openssh-server"],
	}
	
	exec { "add_group_sshusers" :
            command => "groupadd -r sshusers",
               path => '/usr/bin:/usr/sbin:/bin',
             unless => "cat /etc/group | grep sshusers",	
	    require => Package["openssh-server"],
	}

}