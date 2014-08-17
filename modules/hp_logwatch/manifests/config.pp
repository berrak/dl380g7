##
##  Configure logwatch
##
class hp_logwatch::config {
 
 
	file { "/etc/logwatch/logwatch.conf":
		source => "puppet:///modules/hp_logwatch/logwatch.conf",
		 owner => 'root',
		 group => 'root',
		  mode => '0640',
	   require => Package["logwatch"],
    }
	
	file { "/etc/cron.daily/00logwatch":
		source => "puppet:///modules/hp_logwatch/00logwatch",
		 owner => 'root',
		 group => 'root',
		  mode => '0750',
	   require => Package["logwatch"],
    }
		
	# Since we have configured this to be logwatch tmp directory	
	file { "/var/tmp/logwatch":
		ensure => 'directory',
		 owner => 'root',
		 group => 'root',
		  mode => '0770',
	   require => File ["/etc/logwatch/logwatch.conf"],
    }
}