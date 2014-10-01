##
## Manage Puppet
## Note: Oracle Linux 6.X requires puppet-labs repository.
##   Pre-install with: rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
##
class hp_puppetize::install {
  
    include hp_puppetize::params
  
    ## Install puppet agent
	## regardless if this is the puppet server or an agent
  	    
	if $::lsbdistid == 'Debian' {
	
		file { '/root/bin/puppet.exec':
			source => 'puppet:///modules/hp_puppetize/puppet.exec.deb',
			 owner => 'root',
			 group => 'root',
			  mode => '0700',
		}
		
		package { [ 'puppet', 'facter' ] :
				ensure => present,
		 allow_virtual => true,
		}
		
    } elsif $::lsbdistid == 'OracleServer' {
	
		file { '/root/bin/puppet.exec':
			source => 'puppet:///modules/hp_puppetize/puppet.exec.rpm',
			 owner => 'root',
			 group => 'root',
			  mode => '0700',
		}
		
		package { [ 'puppet', 'facter' ] :
				ensure => present,
		 allow_virtual => true,
		}
		
	}
	
	## install some utilities for root
    
    file { '/root/bin' :
        ensure => directory,
         owner => 'root',
         group => 'root',
          mode => '0700',
    }
	
    file { '/root/bin/puppet.simulate':
	    source => 'puppet:///modules/hp_puppetize/puppet.simulate',
	     owner => 'root',
	     group => 'root',
	      mode => '0700',
    }
	
    ## For puppet server
    
    if  $::fqdn in $::hp_puppetize::params::list_puppetservers_fqdn  {
    
		$ostype = $::lsbdistid	
	
		if $ostype == 'Debian' {
		
			package { 'puppetmaster':
				       ensure => latest,
				allow_virtual => true,
			}
		
		} elsif $ostype == 'OracleServer' {
		
			package { 'puppet-server':
				       ensure => latest,
				allow_virtual => true,
			}		
	
		}
		
    } else {
				
		fail("FAIL: Unknown $ostype distribution. Aborting...")
	}

}
