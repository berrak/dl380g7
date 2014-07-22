##
## Puppet configuration
##
class hp_puppetize::config {

    include hp_puppetize::params

    # ensure that the top-files directory exists
    
    file { "/etc/puppet/files" :
        ensure => directory,
        owner => 'root',
        group => 'root',
        require => Class["hp_puppetize::install"],
    }

    # sets e.g. if agent runs as daemon or not 

    file { "/etc/default/puppet" :
        ensure => present,
        source => "puppet:///modules/hp_puppetize/puppet",
        owner => 'root',
        group => 'root',
        require => Class["hp_puppetize::install"],
        notify => Class["hp_puppetize::service"],
    }
    
    if $::fqdn == $::hp_puppetize::params::mypuppetserver_fqdn {
    
        file { "/etc/puppet/puppet.conf" :
            ensure => present,
            source => "puppet:///modules/hp_puppetize/puppet.conf",
            owner => 'root',
            group => 'root',
            require => Class["hp_puppetize::install"],
            notify => Class["hp_puppetize::service"],
        }
        
        file { "/etc/puppet/auth.conf" :
            ensure => present,
            source => "puppet:///modules/hp_puppetize/auth.conf",
            owner => 'root',
            group => 'root',
            require => Class["hp_puppetize::install"],
            notify => Class["hp_puppetize::service"],
        }
        
        file { "/etc/puppet/fileserver.conf" :
            ensure => present,
            source => "puppet:///modules/hp_puppetize/fileserver.conf",
            owner => 'root',
            group => 'root',
            require => Class["hp_puppetize::install"],
            notify => Class["hp_puppetize::service"],
        }
           
              
        # sets e.g. if puppet master runs as daemon or not 
        file { "/etc/default/puppetmaster" :
            ensure => present,
            source => "puppet:///modules/hp_puppetize/puppetmaster",
            owner => 'root',
            group => 'root',
            require => Class["hp_puppetize::install"],
            notify => Class["hp_puppetize::service"],
        }
        
    } 

}