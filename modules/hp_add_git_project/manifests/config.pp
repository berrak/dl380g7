#
# Sample usage:
#
#            hp_add_git_project::config { 'cpan' :
#                           git_name => 'My-Module.git',
#            }
#
define hp_add_git_project::config ( $git_name ) {
  
	if ( $::operatingsystem != 'Debian' ) {
	
		fail("FAIL: This module is only for Debian, not for $::operatingsystem. Aborting...")
	}


	### SET UP USER/PROJECT NAME

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
		     notify => Exec["setup_git_project_user_${name}"],
	}

	
	### SET UP GIT DIRECTORIES (assumes /data exists!)
	
	file { "/data/${name}":
		 ensure => "directory",
		  owner => root,
		  group => "${name}",
		   mode => '0750', 
		require => User[ $name ],
	}
	
	file { "/data/${name}/${git_name}":
		 ensure => "directory",
		  owner => "${name}",
		  group => "${name}",
		   mode => '0750', 
		require => File["/data/${name}"],
		 notify => Exec["setup_git_depot_${name}"],
	}
	
	exec { "setup_git_depot_${name}":
		       path => '/bin:/sbin:/usr/bin:/usr/sbin',
		    command => "git init --bare /data/${name}/${git_name}",
		    require => File["/data/${name}/${git_name}"],
		refreshonly => true,
		     notify => Exec["set_ownership_git_depot_${name}"],		
	}
	
	exec { "set_ownership_git_depot_${name}":
		       path => '/bin:/sbin:/usr/bin:/usr/sbin',
		    command => "chown -R ${name}:${name} /data/${name}/${git_name}",
		    require => File["/data/${name}"],
		refreshonly => true,
	}
	
}
