##
## Manage Puppet (both master and agent)
##
class hp_puppetize {

    include hp_puppetize::install, hp_puppetize::params,
            hp_puppetize::config, hp_puppetize::service
}