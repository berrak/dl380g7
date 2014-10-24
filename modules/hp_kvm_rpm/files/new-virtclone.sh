#!/bin/bash
set -e
#
# /bin/root/new-virtclone.sh
#
# Create a new guest VM from tpldeb (domain template debian wheezy)
#
# Usage: new-virtclone <domain>,
#              e.g. new-virtclone.sh vmg13
# 
if [ $# -ne 1 ] ;
    exit 1
fi

# 1. Replace the old uuid in the new guest doamin xml-file  
cd /etc/libvirt/qemu
create-uuid-in-xml.pl `pwd`/$1.xml

# 2. Register the new guest xml-file for the new domain  
virsh define /etc/libvirt/qemu/$1.xml

# 3. Clone the existing raw image (tpldeb.img) for new guest
virt-clone -o tpldeb -n $1 -f /virtimages/$1.img

# 4. Ajust the new generic image to become host specific

