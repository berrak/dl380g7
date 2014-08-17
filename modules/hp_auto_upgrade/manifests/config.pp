#
# Automatic Debian security updates
#
class hp_auto_upgrade::config {

    file { '/etc/cron.weekly/apt-security-updates':
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

}
