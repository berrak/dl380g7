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
	file { "/root/bin/fw.$myhostname" :
		 source => "puppet:///modules/hp_iptables_rpm/fw.$myhostname",
		  owner => 'root',
		  group => 'root',
		   mode => '0700',
	}
	
	# load firewall at start-up
	file { '/etc/rc.local' :
		source => "puppet:///modules/hp_iptables_rpm/rc.local",
		 owner => 'root',
		 group => 'root',
		  mode => '0700',
	   require => Package['iptables'],
	}
        
	# iptables file to clear all rules and set all policy accept (manual activation)
	file { '/root/bin/fw.clear' :
		 source => "puppet:///modules/hp_iptables_rpm/fw.clear",
		  owner => 'root',
		  group => 'root',
		   mode => '0700',
	}

}
