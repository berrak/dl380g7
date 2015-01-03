#
# Sample usage:
#
#            hp_add_git_project::config { 'cpan' : }
#
define hp_add_git_project::config {
  
	if ( $::operatingsystem != 'Debian' ) {
	
		fail("FAIL: This module is only for Debian, not for $::operatingsystem. Aborting...")
	}

	# add 'user' - holder of ssh-keys for project members 
	user { $name :
		   ensure => present,
		    shell => '/usr/bin/git-shell',
	}
	
	# add password to this 'user'
	$name_password = ${name}:${name}
	
	exec { set_${name}_password":
		command => "/bin/echo \"${name_password}\" | /usr/sbin/chpasswd",
		require => [ $name ],
	
	}
	
	
}
