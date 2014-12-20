##
##  Configure logwatch
##
class hp_logwatch::config {
 
 
	file { "/etc/logwatch/conf/logwatch.conf":
		source => "puppet:///modules/hp_logwatch/logwatch.conf",
		 owner => 'root',
		 group => 'root',
		  mode => '0644',
	   require => Package["logwatch"],
    }
	
	file { "/etc/cron.daily/00logwatch":
		source => "puppet:///modules/hp_logwatch/00logwatch",
		 owner => 'root',
		 group => 'root',
		  mode => '0755',
	   require => Package["logwatch"],
    }
	
	if ( $::operatingsystem == 'OracleLinux' ) {
	
		# remove OracleLinux default cron.daily-file (since we add our own)
		file { "/etc/cron.daily/0logwatch":
		  ensure => absent,
		}
	}
		
}
