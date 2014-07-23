##
## Parameters puppet
##
class hp_puppetize::params {
    
    # List all hosts which also acts as Puppet server on same host as client

    $list_puppetservers_fqdn = [ 'hphome.home.tld', 'hpone.debinix.org' ]

}