#
# Moduhp to manage one central postfix server mta.
# In/outgoing mail via ISP smtp host. 
#
class hp_postfix {

    include hp_postfix::params, hp_postfix::install, hp_postfix::service

}