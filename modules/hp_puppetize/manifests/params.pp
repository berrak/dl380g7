##
## Parameters puppet
##
class hp_puppetize::params {
    
    # List all hosts which also acts as Puppet server on same host as client
    # Note: only used if puppet agent is running (in daemon mode)

    $list_puppetservers_fqdn = [ 'hphome.home.tld', 'dl380g7.debinix.org',
                                 'ol65.home.tld', 'hp.home.tld' ]
                                 
    # hard-code the puppet-server domain details - otherwise a system that does
    # not run in the same domain fails (e.g behing NAT or in a LXC container)
    
    $server_domain_home = 'home.tld'
    $server_domain_bahnhof = 'debinix.org'

}