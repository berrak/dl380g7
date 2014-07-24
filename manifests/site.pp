#
## site.pp
#
include 'base.pp'

node 'node-hphome.home.tld' inherits basenode {

	# manage puppet
    include hp_puppetize

}
#
## eof
#