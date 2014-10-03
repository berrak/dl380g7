##
## Puppet manage openssh server
##
class hp_ssh_server::config {
    
    $myhostname = $::hostname
	
	$ostype = $::lsbdistid
	
	if $ostype == 'Debian' {
		$sshservicename = 'ssh'
	} elsif $ostype == 'OracleServer' {
		$sshservicename = 'sshd'
	} else {
		fail("FAIL: Unknown $ostype distribution. Aborting...")
	}
	
	file { '/etc/ssh/sshd_config' :
           source => "puppet:///modules/hp_ssh_server/sshd_config",		  
			owner => 'root',
			group => 'root',
		  require => Package["openssh-server"],
		   notify => Service[$sshservicename],
	}
	
	# our custom ssh login banner (warning for unauthorized access)
	
	file { '/etc/issue.net' :
           source => "puppet:///modules/hp_ssh_server/issue.net",		  
			owner => 'root',
			group => 'root',
		  require => Package["openssh-server"],
	}
	
	# only non-priveleged users in this group are allowed to ssh-login
	exec { "add_group_sshusers" :
            command => "groupadd -r sshusers",
               path => '/usr/bin:/usr/sbin:/bin',
             unless => "cat /etc/group | grep sshusers",	
	    require => Package["openssh-server"],
	}

}