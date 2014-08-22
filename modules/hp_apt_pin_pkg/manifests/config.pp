##
## This configures additional Debian releases
#
# Sample usage:
#
#     hp_apt_pin_pkg::config{ 'lynis' :
#                        pin_priority => '995',
#                             release => 'testing', }
#       
##
define hp_apt_pin_pkg::config ( $pin_priority = '', $release = '' ) {


    if $name == ''  {
		fail("FAIL: Package $name is not given!")
	}
	
    if $pin_priority == ''  {
		fail("FAIL: Package pin priority is missing!")
	}
	
    if $release == ''  {
		fail("FAIL: Target release is missing!")
	}	

	# Check that release sources list file exist
	
	if ! defined(File["/etc/apt/sources.list.d/$release.list"]) {
		fail("FAIL: The requested debian release $release have not been added to sources.list.d!")
	 }
	
	file { "/etc/apt/sources.list.d/$name.list":
		source => "puppet:///modules/hp_apt_pin_pkg/$name.sources.list",
		 owner => "root",
		 group => "root",
		  mode => '0644',
	}

    # Set preference priority
	
	file { "/etc/apt/preferences.d/$name.pref":
	   content =>  template( "hp_apt_pin_pkg/preferences.$name.erb" ),   	
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
