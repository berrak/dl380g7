#
# site.pp
#

import 'base.pp'

node 'node-hphome.home.tld' {

    include hp_puppetize

}
