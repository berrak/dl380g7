#
# Configure logrotate. 
#
class hp_logrotate::config {

    $mydomain = $::domain

    file { '/etc/logrotate.conf':
        content =>  template('hp_logrotate/logrotate.conf.erb'),
          owner => 'root',
          group => 'root',       
        require => Class["hp_logrotate::install"],
    }
    
}