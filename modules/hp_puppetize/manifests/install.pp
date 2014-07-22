##
## Manage Puppet
##
class hp_puppetize::install {
  
    include hp_puppetize::params
  
    # Debian defaults to install puppet-common which
    # depends on facter - but just to show both.
  
    # Install puppet agent regardless if this is the puppet server or agent
  
    package { [ "puppet", "facter" ] :
        ensure => present,
    }
	
    # install some utilities for root
    
    file { "/root/bin" :
        ensure => directory,
         owner => 'root',
         group => 'root',
          mode => '0700',
    }
    
    file { "/root/bin/puppet.exec":
	    source => "puppet:///modules/hp_puppetize/puppet.exec",
	     owner => 'root',
	     group => 'root',
	      mode => '0700',
    }
    
    file { "/root/bin/puppet.simulate":
	    source => "puppet:///modules/hp_puppetize/puppet.simulate",
	     owner => 'root',
	     group => 'root',
	      mode => '0700',
    }
	
  
    # For puppet server
    
    if $::fqdn == $::hp_puppetize::params::mypuppetserver_fqdn {
    
	  package { "puppetmaster" :
	    ensure => present,
	  }
	    
    }

}