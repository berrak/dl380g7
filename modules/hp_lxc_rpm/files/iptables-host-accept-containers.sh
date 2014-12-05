#!/bin/bash
#
# /containers/common-hooks/iptables-host-accept-containers.sh
#
# iptables rules to add at top (before) virbr0 INPUT chain to
# allow certain traffic from container to host e.g. puppet agent.
#
#
###############################################################
# ACCEPT RULES BEGINS HERE (ADDITIONAL IPTABLES RULES)
###############################################################
#
## ============================================================
##   PRE/POST ROUTING NAT
## ============================================================
#
# pre-route traffic to pseudo-eth0 (192.168.0.40) to correct container eth0 interface
iptables -t nat -L -v --line-numbers | grep to:192.168.122.40
if [ "$?" != "0" ] ; then
    iptables -t nat -A PREROUTING -d 192.168.0.40 -j DNAT --to-destination 192.168.122.40
fi
# pre-route traffic to pseudo-eth0 (192.168.0.41) to correct container eth0 interface
iptables -t nat -L -v --line-numbers | grep to:192.168.122.41
if [ "$?" != "0" ] ; then
    iptables -t nat -A PREROUTING -d 192.168.0.41 -j DNAT --to-destination 192.168.122.41
fi
# pre-route traffic to pseudo-eth0 (192.168.0.42) to correct container eth0 interface
iptables -t nat -L -v --line-numbers | grep to:192.168.122.42
if [ "$?" != "0" ] ; then
    iptables -t nat -A PREROUTING -d 192.168.0.42 -j DNAT --to-destination 192.168.122.42
fi
# pre-route traffic to pseudo-eth0 (192.168.0.43) to correct container eth0 interface
iptables -t nat -L -v --line-numbers | grep to:192.168.122.43
if [ "$?" != "0" ] ; then
    iptables -t nat -A PREROUTING -d 192.168.0.43 -j DNAT --to-destination 192.168.122.43
fi
# pre-route traffic to pseudo-eth0 (192.168.0.44) to correct container eth0 interface
iptables -t nat -L -v --line-numbers | grep to:192.168.122.44
if [ "$?" != "0" ] ; then
    iptables -t nat -A PREROUTING -d 192.168.0.44 -j DNAT --to-destination 192.168.122.44
fi

## ============================================================
##   LXC TRAFFIC (CONTAINER OUTBOUND TO HOST)
## ============================================================

# puppet server listen port 8140 from all container agents
iptables -L -v --line-numbers | grep dpt:8140
if [ "$?" != "0" ] ; then
    iptables -I INPUT 1 -i virbr0 -p tcp -m tcp --dport 8140 -m state --state NEW -j ACCEPT
fi

## ============================================================
##  DANGER *** INBOUND TRAFFIC (TO CONTAINERS) *** DANGER
## ============================================================

# accept incoming public ssh/DNAT traffic to containers
iptables -L -v --line-numbers | grep dpt:ssh
if [ "$?" != "0" ] ; then
    iptables -I FORWARD 1 -i eth0 -o virbr0 -p tcp -m tcp --dport 22 -m state --state NEW -j ACCEPT
fi

# accept incoming public http/DNAT traffic to containers
iptables -L -v --line-numbers | grep dpt:http
if [ "$?" != "0" ] ; then
    iptables -I FORWARD 1 -i eth0 -o virbr0 -p tcp -m tcp --dport 80 -m state --state NEW -j ACCEPT
fi

