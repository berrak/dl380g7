##
## Manage rsyslog
##
class hp_rsyslog::params {

    ## log server (i.e. the receiving log host)

    $myloghost_ip = '217.70.39.231'  ## mc-butter ##
    
    # all logfiles that rsyslog writes (local or remote) here will be checked
    
    $logcheckfilespath = '/var/log/logcheck'
    
}