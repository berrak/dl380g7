#
# Sample usage:
#
#            hp_add_git_project::config { 'cpan' : }
#
define hp_add_git_project::config {
  
	if ( $::operatingsystem != 'Debian' ) {
	
		fail("FAIL: This module is only for Debian, not for $::operatingsystem. Aborting...")
	}

    # create user/group with name of project
	exec { "create_project_${name}" :
		   path => '/bin:/sbin:/usr/bin:/usr/sbin',
		command => "useradd --shell /usr/bin/git-shell $name", 
		 unless => "cat /etc/passwd | grep $name",
		 notify => Exec["create_project_${name}_password"],
	}
	
	# unsecure passwd
	$name_password = "$name:$name"
	
	exec { "create_project_${name}_password" :
		       path => '/bin:/sbin:/usr/bin:/usr/sbin',
		    command => "echo '"$name_password"' | chpasswd $name", 
		   required => Exec["create_project_${name}"],
		refreshonly => true,
	}
	
}
