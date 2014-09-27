##
## Puppet service.
##
class hp_puppetize::service {

    include hp_puppetize::params

    # Reloads puppet agent.
	
	## Debian default config:
	## In file /etc/default/puppet, default setting for
    # agent is 'stopped'. If this is not wanted, configure that file.
    # and change 'ensure' below with 'ensure => running'
	
	## OracleLinux default config: unknown
    
    service { 'puppet_agent':
              name => 'puppet',
	    hasrestart => true,
            enable => true,
            ensure => stopped,
	       require => Class['hp_puppetize::install'],
    }
	
    # For the puppet server only
	
    if $::fqdn in $::hp_puppetize::params::list_puppetservers_fqdn {

        service { 'puppetmaster':
	    hasrestart => true,
                enable => true,
                ensure => running,
               require => Class['hp_puppetize::install'],
        }
    
    } 

}