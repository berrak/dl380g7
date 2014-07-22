##
## Puppet service.
##
class hp_puppetize::service {

    include hp_puppetize::params


    # Reloads puppet agent. Debian default (/etc/default/puppet) ensures
    # agent is NOT running. If this is not wanted, configure that file.
    # and change 'ensure' below with 'ensure => running'
    
    service { "puppet_agent":
                  name => 'puppet',
	    hasrestart => true,
                enable => true,
                ensure => running,
	       require => Class["hp_puppetize::install"],
    }
	
    # For the puppet server only
	
    if $::fqdn == $::puppetize::params::mypuppetserver_fqdn {

        service { "puppetmaster":
	    hasrestart => true,
                enable => true,
                ensure => running,
               require => Class["hp_puppetize::install"],
        }
    
    } 

}