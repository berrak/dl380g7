#
# Sample usage:
#
#            hp_add_git_project::config { 'cpan' : }
#
define hp_add_git_project::config {
  
	if ( $::operatingsystem != 'Debian' ) {
	
		fail("FAIL: This module is only for Debian, not for $::operatingsystem. Aborting...")
	}

	# add user and password to this 'user'
	$password = $name
	user { $name :
		   ensure => present,
		    shell => '/usr/bin/git-shell',
		 password => generate('/bin/sh', '-c', "mkpasswd -m sha-512 ${password} | tr -d '\n'"),
	}
	
}
