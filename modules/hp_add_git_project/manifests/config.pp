#
# Sample usage:
#
#            hp_add_git_project::config { 'cpan' : }
#
define hp_add_git_project::config {
  
	if ( $::operatingsystem != 'Debian' ) {
	
		fail("FAIL: This module is only for Debian, not for $::operatingsystem. Aborting...")
	}

	# add 'user' (and group) - holder of ssh-keys for project members 
	user { $name :
		    ensure => present,
		     shell => '/usr/bin/git-shell',
		    notify => Exec["set_${name}_password"],
	}

	file { "/home/${name}":
		 ensure => "directory",
		  owner => "${name}",
		  group => "${name}",
		require => User[ $name ],
	}
	
	file { "/home/${name}/.ssh":
		 ensure => "directory",
		  owner => "${name}",
		  group => "${name}",
		require => File["/home/${name}"],
	}

	# add password to this 'user'
	$pwd = "${name}:${name}"
	
	exec { "set_${name}_password":
		    command => "/bin/echo \"${pwd}\" | /usr/sbin/chpasswd",
		    require => User[ $name ],
		refreshonly => true,
	}
	
	
}
