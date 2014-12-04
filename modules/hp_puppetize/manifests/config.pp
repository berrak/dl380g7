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
    $mydomain = $::domain
    
    ## NOTE: This needs to be updated for LXC continers at target deployment
    
    case $myhostname {
        'ol65', 'hphome': { $myserverdomain = $::hp_puppetize::params::server_domain_home }
        'dl380g7': { $myserverdomain = $::hp_puppetize::params::server_domain_bahnhof }
        'deborg','trise','kronlund','git','mc': { $myserverdomain = $::hp_puppetize::params::server_domain_home }
        default: { fail("FAIL: Puppet server domain is missing from puppetize params-file") }
    }
    
    ## DEBIAN 7
    
    if $::operatingsystem == 'Debian' {
            
        file { '/etc/puppet/puppet.conf' :
            ensure => present,
           content =>  template( 'hp_puppetize/puppet.conf.deb.erb' ),    
             owner => 'root',
             group => 'root',
           require => Class['hp_puppetize::install'],
            notify => Class['hp_puppetize::service'],
        }
        
        # Client options: Sets if puppet agent daemon 'runs' or is 'stopped' (=default)
        file { '/etc/default/puppet' :
            ensure => present,
           content =>  template( 'hp_puppetize/puppet.deb.erb' ),         
             owner => 'root',
             group => 'root',
           require => Class['hp_puppetize::install'],
            notify => Class['hp_puppetize::service'],
        }
        
    }
    
    ## Oracle Linux 6.5 (runs Puppet 3.7)
    
    if $::operatingsystem == 'OracleLinux' {
            
        file { '/etc/puppet/puppet.conf' :
            ensure => present,
           content =>  template( 'hp_puppetize/puppet.conf.rpm.erb' ),    
             owner => 'root',
             group => 'root',
           require => Class['hp_puppetize::install'],
            notify => Class['hp_puppetize::service'],
        }
        
        # Ensure no puppet daemon start at boot
		
		exec { 'Ensure_puppet_agent_daemon_not_running_at_boot':
			  command => '/sbin/chkconfig puppet off',
			     path => '/usr/bin:/usr/sbin:/bin:/sbin',
			subscribe => File['/etc/puppet/puppet.conf'],
          refreshonly => true,
		}
        
        # Client options: customize
        file { '/etc/sysconfig/puppet' :
            ensure => present,
           content =>  template( 'hp_puppetize/puppet.rpm.erb' ),         
             owner => 'root',
             group => 'root',
           require => Class['hp_puppetize::install'],
            notify => Class['hp_puppetize::service'],
        }    
        
    }    
  
    if $puppetsrvfqdn in $::hp_puppetize::params::list_puppetservers_fqdn {

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

        ## DEBIAN PUPPETMASTER OPTIONS
        if $::operatingsystem == 'Debian' {
        
            # sets e.g. if puppetmaster runs as daemon (default) or not
            file { '/etc/default/puppetmaster' :
                ensure => present,
                source => 'puppet:///modules/hp_puppetize/puppetmaster-deb',
                 owner => 'root',
                 group => 'root',
               require => Class['hp_puppetize::install'],
                notify => Class['hp_puppetize::service'],
            }
        }
        
        ## OL6 PUPPETMASTER OPTIONS
        if $::operatingsystem == 'OracleLinux' {
        
            # sets e.g. if puppetmaster runs as daemon (default) or not
            file { '/etc/sysconfig/puppetmaster' :
                ensure => present,
                source => 'puppet:///modules/hp_puppetize/puppetmaster-rpm',
                 owner => 'root',
                 group => 'root',
               require => Class['hp_puppetize::install'],
                notify => Class['hp_puppetize::service'],
            }
        }     
        ## DISABLE -- rewrite module set parameter from site.pp
        # install job for puppetserver to pull updates from dl380g7.git repo
        #file { '/etc/cron.daily/puppet-gitpull.sh' :
        #    ensure => present,
        #    source => 'puppet:///modules/hp_puppetize/puppet-gitpull.sh',
        #     owner => 'root',
        #     group => 'root',
        #      mode => '0755',
        #   require => Class['hp_puppetize::install'],
        #}        

    }

}