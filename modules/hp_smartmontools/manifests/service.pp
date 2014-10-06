##
## This class manage disk status med S.M.A.R.T.
##
class hp_smartmontools::service {
    
	include hp_smartmontools::install
	
	service { "smartd" :
			ensure => running,
		 hasstatus => true,
		hasrestart => true,
			enable => true,
		   require => Package["smartmontools"],
	}
	
}