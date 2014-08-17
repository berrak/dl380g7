#
# Manage 'rsyslog' 
#
class hp_rsyslog {

    include hp_rsyslog::install, hp_rsyslog::config, hp_rsyslog::params, hp_rsyslog::service

}