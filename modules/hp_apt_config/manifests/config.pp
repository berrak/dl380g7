##
## This class configures APT
##
class hp_apt_config::config {

	# Sources: Default to Debian Wheezy, Debian Security and Debian Update

	file { "/etc/apt/sources.list":
		source => "puppet:///modules/hp_apt_config/sources.list",
		 owner => "root",
		 group => "root",
		  mode => '0644',
	}

	## Configuration for APT - Do not install pkg recommends/suggests by default
	
	file { "/etc/apt/apt.conf":
		source => "puppet:///modules/hp_apt_config/apt.conf",
		 owner => 'root',
		 group => 'root',
		  mode => '0644',

	}
	
    # Set preference release to stable (always)
	
	file { "/etc/apt/preferences":
		source => "puppet:///modules/hp_apt_config/preferences",
		 owner => "root",
		 group => "root",
		  mode => '0644',
		  require => File['/etc/apt/sources.list'],
	}
	
}
