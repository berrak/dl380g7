#!/bin/bash
#
# /containers/common-hooks/iptables-host-accept-containers.sh
#
# iptables rules to add at top (before) virbr0 INPUT chain to
# allow certain traffic from container to host e.g. puppet agent.
#
#
###############################################################
# ACCEPT RULES BEGINS HERE
###############################################################
# puppet server listen port 8140 from container agents
iptables -L -v --line-numbers | grep dpt:8140
if [ "$?" != "0" ] ; then
    iptables -I INPUT 1 -i virbr0 -p tcp -m tcp --dport 8140 -m state --state NEW -j ACCEPT
fi
# accept incoming public http/DNAT traffic to containers
iptables -L -v --line-numbers | grep dpt:80
if [ "$?" != "0" ] ; then
    iptables -I FORWARD 1 -i eth0 -o virbr0 -p tcp -m tcp --dport 80 -m state --state NEW -j ACCEPT
fi