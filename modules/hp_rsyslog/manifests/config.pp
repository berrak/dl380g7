#
# Configure rsyslog. 
#
class hp_rsyslog::config {

    include hp_rsyslog::params
    
    $myloghost_ip = $::hp_rsyslog::params::myloghost_ip
    
    if $::ipaddress == $myloghost_ip {
     
        include hp_rsyslog::params
         
        # where logfiles are saved for logcheck scans
        $logcheckfilepath = $::hp_rsyslog::params::logcheckfilespath
        
        file { '/etc/rsyslog.conf':
            ensure  => present,
            content => template("hp_rsyslog/rsyslog.loghost.conf.erb"),            
            owner   => 'root',
            group   => 'root',
            require => Class["hp_rsyslog::install"],
             notify => Class["hp_rsyslog::service"],
        }
        
        
        # use cron to update any new hosts and their remote log files on loghost
        
        file { '/etc/cron.d/remoteloghostupdate':
             source => "puppet:///modules/hp_rsyslog/remoteloghostupdate",
              owner => 'root',
              group => 'root',
               mode => '0644',
            require => File["/root/jobs/cron.update_remote_log_directories"],
        }
		
		# ensure that the directory referred by above script exist
		
        file { "/var/log/REMOTELOGS" :
            ensure => directory,
        	 owner => 'root',
	 	     group => 'adm',
		      mode => '0755',
           require => Class["hp_rsyslog::install"],              
        }				
        
        # this script add logs to logcheck to scan, and make sure files get rotated
        
        file { '/root/jobs/cron.update_remote_log_directories':
             source => "puppet:///modules/hp_rsyslog/cron.update_remote_log_directories",
              owner => 'root',
              group => 'root',
               mode => '0700',
            require => File["$logcheckfilepath"],
        }             
        
        # create a directory for all logs (local and remote) for 'logcheck' to
        # scan. Note: Need group to be 'adm' (since logcheck belongs to 'adm')
        
        file { "$logcheckfilepath" :
            ensure => directory,
        	 owner => 'root',
	 	     group => 'adm',
		      mode => '0755',
           require => Class["hp_rsyslog::install"],              
        }
        
        # write some notes to admin where we put syslog(.log) when using logcheck
        
        file { '/var/log/syslogforadmin.README':
             source => "puppet:///modules/hp_rsyslog/syslogforadmin.README",
              owner => 'root',
              group => 'root',
               mode => '0640',
           require => Class["hp_rsyslog::install"],    
        }  
        
        
        
    
    } else {
    
        file { '/etc/rsyslog.conf':
             source => "puppet:///modules/hp_rsyslog/rsyslog.conf",
              owner => 'root',
              group => 'root',
            require => Class["hp_rsyslog::install"],
             notify => Class["hp_rsyslog::service"],
        }
    
    }
    
    # logger wrapper script to test facilities.priorities at command line 
    
    file { '/root/bin/rsyslog.test':
         source => "puppet:///modules/hp_rsyslog/rsyslog.test",
          owner => 'root',
          group => 'root',
           mode => '0700',
        require => Class["hp_rsyslog::install"],
    }  
    
}