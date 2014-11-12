#
# Manage apache2 reverse proxy for NAT VM's
#
class hp_apache_rev_proxy {

    include hp_apache_rev_proxy::install, hp_apache_rev_proxy::config, hp_apache_rev_proxy::service

}