##
## Manage rsyslog
##
class hp_rsyslog::params {

    ## log server (i.e. the receiving log host)

    $myloghost_ip = ''
    
    # all logfiles that rsyslog writes (local or remote) here will be checked
    
    $logcheckfilespath = '/var/log/logcheck'
    
}