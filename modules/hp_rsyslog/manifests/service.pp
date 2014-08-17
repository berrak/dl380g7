#
# Start the rsyslog daemon.
#
class hp_rsyslog::service {

    service { 'rsyslog':
        ensure => running,
        enable => true,
        require => Class["hp_rsyslog::config"],
    }
}