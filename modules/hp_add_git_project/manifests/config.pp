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
		 notify => User["$name"],
	}
	
	# add password to this 'user'
	$password = $name
	user { $name :
		  ensure => present,
		password => generate('/bin/sh', '-c', "mkpasswd -m sha-512 ${password} | tr -d '\n'"),
		 require => Exec["create_project_${name}"],
	}
	
}
