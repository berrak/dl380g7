##
##  Configure screen
##
class hp_screen::config {
 
	# systemwide screen resource file 
 
	file { "/etc/screenrc":
		source => "puppet:///modules/hp_screen/screenrc",
		 owner => 'root',
		 group => 'root',
		  mode => '0640',
	   require => Package["screen"],
    }
	
}