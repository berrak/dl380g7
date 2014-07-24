#!/bin/sh
##############################################################
# Do not edit. Managed by Puppet. Changes will be wiped out. #
##############################################################
# /etc/cron.daily/puppet-gitpull.sh
#
# Pull updates on daily basis from my GitHub dl380g7 repository
# (the remote repository is defined when git is configured)
##############################################################
# Only do anything if git is actually installed
if [ ! -x /usr/bin/git ]; then
  exit 0
fi
# Only do anything if puppet server is actually installed
if [ -d "/etc/puppet" ]; then
    cd /etc/puppet
    /usr/bin/git pull
fi