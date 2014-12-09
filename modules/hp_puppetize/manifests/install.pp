##
## Manage Puppet (3.7.x)
##
## Note: Oracle Linux 6 requires puppet-labs repository.
##   Update repositories with: rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
## Note: Debian Wheezy requires puppet-labs repository.
##   Update repositories with: wget http://apt.puppetlabs.com/puppetlabs-release-wheezy.deb
##
class hp_puppetize::install {
  
    include hp_puppetize::params
  
    ## Install puppet agent
	## regardless if this is the puppet server or an agent
  	    
	if $::operatingsystem == 'Debian' {
	
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
		
    } elsif $::operatingsystem == 'OracleLinux' {
	
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
    
		$ostype = $::operatingsystem	
	
		if $ostype == 'Debian' {
		
			package { 'puppetmaster':
				       ensure => latest,
				allow_virtual => true,
			}
		
		} elsif $ostype == 'OracleLinux' {
		
			package { 'puppet-server':
				       ensure => latest,
				allow_virtual => true,
			}		
	
		} else {
			fail("FAIL: Unknown $ostype distribution. Aborting...")
		}
		
	}

}
