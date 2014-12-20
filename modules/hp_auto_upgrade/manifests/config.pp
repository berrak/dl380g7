#
# Automatic Debian security updates
#
class hp_auto_upgrade::config {

    if $::lsbdistid == 'Debian' {

        file { '/etc/cron.daily/apt-security-updates':
             source => "puppet:///modules/hp_auto_upgrade/apt-security-updates",
              owner => 'root',
              group => 'root',
               mode => '0755',
        }
    
        file { '/etc/logrotate.d/log-security-updates':
             source => "puppet:///modules/hp_auto_upgrade/log-security-updates",
              owner => 'root',
              group => 'root',
               mode => '0644',
        }
    } elsif $::operatingsystem == 'OracleLinux' {
    
        file { '/etc/cron.daily/yum-auto-updates':
             source => "puppet:///modules/hp_auto_upgrade/yum-auto-updates",
              owner => 'root',
              group => 'root',
               mode => '0755',
        }
    
    } else {
    	fail("FAIL: Unknown $ostype distribution. Aborting...")
    }

}
