##
## This class manage ebtables
## 
class hp_ebtables_rpm::config  {

	include hp_ebtables_rpm::install, hp_ebtables_rpm::service
	
	$myhostname = $::hostname

	# configuration for ebtables
	file { '/etc/sysconfig/ebtables-config' :
		source => "puppet:///modules/hp_ebtables_rpm/ebtables-config.${myhostname}",
		 owner => 'root',
		 group => 'root',
		  mode => '0600',
	   require => Package['ebtables'],
	    notify => Service['ebtables'],
	}

	# ebtables file in production (manual activation)
	file { "/root/bin/eb.${myhostname}" :
		 source => "puppet:///modules/hp_ebtables_rpm/eb.${myhostname}",
		  owner => 'root',
		  group => 'root',
		   mode => '0700',
	}
	
	# ebtables file for initial setup (manual activation)
	file { '/root/bin/eb.init' :
		 source => "puppet:///modules/hp_ebtables_rpm/eb.init",
		  owner => 'root',
		  group => 'root',
		   mode => '0700',
	}
	

        


}
