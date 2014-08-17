#
# Configure logrotate. 
#
class hp_logrotate::config {

    # facter

    $mydomain = $::domain

    file { '/etc/logrotate.conf':
        content =>  template('hp_logrotate/logrotate.conf.erb'),
          owner => 'root',
          group => 'root',       
        require => Class["hp_logrotate::install"],
    }
    
    # snippets go into the /logrotate.d
    
    file { '/etc/logrotate.d/rsyslog':
         source => "puppet:///modules/hp_logrotate/rsyslog",    
          owner => 'root',
          group => 'root',
        require => Class["hp_logrotate::install"],
    }
    
}