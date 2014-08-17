##
## Class to manage mutt Mail User Agent (mua).
##
class hp_mutt {

    include hp_mutt::params
    
    package { "mutt" : ensure => present }

}