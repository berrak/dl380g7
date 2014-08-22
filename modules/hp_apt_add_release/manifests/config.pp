##
## This configures additional Debian releases
#
# Sample usage:
#
#     hp_apt_add_release::config{ 'testing' :
#                        pin_priority => '90' }
#       
##
define hp_apt_add_release::config ( $pin_priority = '') {


    if $name != in [ 'testing' ] {
		fail("FAIL: $name is not supported as an additional release to add to stable!")
	}


	# Add the named Debian release

	file { "/etc/apt/sources.list.d/$name.list":
		source => "puppet:///modules/hp_apt_add_release/$name.sources.list",
		 owner => "root",
		 group => "root",
		  mode => '0644',
	}

    # Set preference priority
	
	file { "/etc/apt/preferences.d/$name.pref":
	   content =>  template( "hp_apt_add_release/preferences.$name.erb" ),   	
		 owner => "root",
		 group => "root",
		  mode => '0644',
	   require => File["/etc/apt/sources.list.d/$name.list"],
	}

    # Update APT cache, but only when preferences file changes

	exec { "/usr/bin/aptitude update" :
		subscribe   => File["/etc/apt/preferences.d/$name.pref"],
		refreshonly => true
	}	
	
	
}
