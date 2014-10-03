##
## This class manage DNS, resolv.conf and the 'hosts' file
##
class hp_dnsmasq {

    include hp_dnsmasq::install, hp_dnsmasq::config, hp_dnsmasq::service

}
