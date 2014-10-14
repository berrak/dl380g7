##
## This class manage iptables
## 
class hp_iptables_rpm::config  {

	include hp_iptables_rpm::install, hp_iptables_rpm::service
	
	$myhostname = $::hostname

	# configuration for iptables
	file { '/etc/sysconfig/iptables-config' :
		source => "puppet:///modules/hp_iptables_rpm/iptables-config.${myhostname}",
		 owner => 'root',
		 group => 'root',
		  mode => '0600',
	   require => Package['iptables'],
	    notify => Service['iptables'],
	}

	# iptables file in production (manual activation)
	file { "/root/bin/fw.${myhostname}" :
		 source => "puppet:///modules/hp_iptables_rpm/fw.${myhostname}",
		  owner => 'root',
		  group => 'root',
		   mode => '0700',
	}
	
	# iptables file for initial development setup (manual activation)
	file { '/root/bin/fw.init' :
		 source => "puppet:///modules/hp_iptables_rpm/fw.init",
		  owner => 'root',
		  group => 'root',
		   mode => '0700',
	}
	
	# iptables file to clear all rules and set policy accept (manual activation)
	file { '/root/bin/fw.open' :
		 source => "puppet:///modules/hp_iptables_rpm/fw.open",
		  owner => 'root',
		  group => 'root',
		   mode => '0700',
	}
        


}
