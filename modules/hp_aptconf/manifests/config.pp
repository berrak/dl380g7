##
## This class configures APT
##
class hp_aptconf::config {


	# Debian Wheezy, Debian security and Debian Update repos

	file { "/etc/apt/sources.list":
		source => "puppet:///modules/hp_aptconf/sources.list",
		 owner => "root",
		 group => "root",
		  mode => '0644',
	}

	## Configuration for APT - Do not install recommends/suggests by default
	
	file { "/etc/apt/apt.conf":
		source => "puppet:///modules/hp_aptconf/apt.conf",
		 owner => 'root',
		 group => 'root',
		  mode => '0644',

	}	
	
}
