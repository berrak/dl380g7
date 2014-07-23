##
## Puppet configuration
##
class hp_puppetize::config {

    include hp_puppetize::params

    # ensure that the top-files directory exists

    file { '/etc/puppet/files' :
        ensure => directory,
         owner => 'root',
         group => 'root',
       require => Class['hp_puppetize::install'],
    }

    # used template variables
    $puppetsrvfqdn = $::fqdn
    $myhostname = $::hostname
    
    # sets e.g. if agent runs as daemon or not (default)
    file { '/etc/default/puppet' :
        ensure => present,
       content =>  template( 'hp_puppetize/puppet.erb' ),         
         owner => 'root',
         group => 'root',
       require => Class['hp_puppetize::install'],
        notify => Class['hp_puppetize::service'],
    }
  
    if $puppetsrvfqdn in $::hp_puppetize::params::list_puppetservers_fqdn {

        file { '/etc/puppet/puppet.conf' :
            ensure => present,
           content =>  template( 'hp_puppetize/puppet.conf.erb' ),    
             owner => 'root',
             group => 'root',
           require => Class['hp_puppetize::install'],
            notify => Class['hp_puppetize::service'],
        }

        file { '/etc/puppet/auth.conf' :
            ensure => present,
            source => 'puppet:///modules/hp_puppetize/auth.conf',
             owner => 'root',
             group => 'root',
           require => Class['hp_puppetize::install'],
            notify => Class['hp_puppetize::service'],
        }

        file { '/etc/puppet/fileserver.conf' :
            ensure => present,
            source => 'puppet:///modules/hp_puppetize/fileserver.conf',
             owner => 'root',
             group => 'root',
           require => Class['hp_puppetize::install'],
            notify => Class['hp_puppetize::service'],
        }

        # sets e.g. if puppet master runs as daemon (default) or not
        file { '/etc/default/puppetmaster' :
            ensure => present,
            source => 'puppet:///modules/hp_puppetize/puppetmaster',
             owner => 'root',
             group => 'root',
           require => Class['hp_puppetize::install'],
            notify => Class['hp_puppetize::service'],
        }

    }

}