##
## This class manage disk status med S.M.A.R.T.
##
class hp_smartmontools::config {

    include hp_smartmontools::install, hp_smartmontools::service
    
    # configuration for smartd
	file { '/etc/smartd.conf' :
           source => "puppet:///modules/hp_smartmontools/smartd.conf",		  
			owner => 'root',
			group => 'root',
		  require => Package["smartmontools"],
		   notify => Service["smartd"],
	}

    # command line options for smartd
	file { '/etc/sysconfig/smartmontools' :
           source => "puppet:///modules/hp_smartmontools/smartmontools",		  
			owner => 'root',
			group => 'root',
		  require => Package["smartmontools"],
	}

}
