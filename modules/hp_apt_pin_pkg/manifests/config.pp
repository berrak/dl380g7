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

    # Set preference priority
	
	file { "/etc/apt/preferences.d/$name.pref":
	   content =>  template( "hp_apt_pin_pkg/preferences.$name.erb" ),   	
		 owner => "root",
		 group => "root",
		  mode => '0644',
	   require => File["/etc/apt/sources.list.d/$release.list"],
	}
	
}
