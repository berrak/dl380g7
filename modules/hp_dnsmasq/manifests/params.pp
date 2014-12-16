##
## This class manage DNS, resolv.conf and the 'hosts' file
##
class hp_dnsmasq::params {

    # hostnames of puppet servers
    $puppet_server_list = [ "ol65", "hp" ] 
 
}
