##
## This configures additional Debian releases
#
# Sample usage:
#
#     hp_add_apt_release::config{ 'testing' : }
#     hp_add_apt_release::config{ 'wheezy-backports' : }
#       
##
define hp_add_apt_release::config {

	if ( $::operatingsystem != 'Debian' ) {
	
		fail("FAIL: This module is only for Debian! Aborting...")
	}

    if ( $name == 'testing' ) {

		# Add the testing (Jessie) Debian testing release
		
		file { "/etc/apt/sources.list.d/$name.list":
			source => "puppet:///modules/hp_add_apt_release/$name.sources.list",
			 owner => "root",
			 group => "root",
			  mode => '0644',
		}
	
		# Set preference release to stable (always)
		
		file { "/etc/apt/preferences":
			source => "puppet:///modules/hp_add_apt_release/preferences",
			 owner => "root",
			 group => "root",
			  mode => '0644',
			  require => File["/etc/apt/sources.list.d/$name.list"],
		}	
	
		# Update APT cache, but only when preferences file changes
	
		exec { "/usr/bin/aptitude update" :
			subscribe   => File["/etc/apt/preferences"],
			refreshonly => true
		}
		
	} elsif ( $name == 'wheezy-backports' ) {
	
		# Add the wheezy-backports release
		file { "/etc/apt/sources.list.d/$name.list":
			source => "puppet:///modules/hp_add_apt_release/$name.sources.list",
			 owner => "root",
			 group => "root",
			  mode => '0644',
		}
	
	
	} else {
	
		fail("FAIL: Only testing and wheezy-backports are allowed as additional releases to add to stable!")
	}
	
	
}
