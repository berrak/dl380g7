#!/bin/bash
#
# /bin/root/new-virtclone.sh
#
# Create a new guest VM from tpldeb (domain template debian wheezy)
#
# Usage: new-virtclone <domain>,
#              e.g. new-virtclone.sh vmg13
#
PROGNAME=$(basename $0)
if [ $# -ne 1 ] ; then
    logger -s "$PROGNAME: Wrong number of arguments $#"
    exit 1
fi

# 1. Replace the old uuid in the new guest doamin xml-file
create-uuid-in-xml.pl /etc/libvirt/qemu/$1.xml
logger -s "$PROGNAME: Created unique uuid for new virtual domain $1"

# 2. Undefine domain if existing
virsh undefine $1

# 3. Register the new guest xml-file for the new domain
virsh define /etc/libvirt/qemu/$1.xml
logger -s "$PROGNAME: Registred new domain $1"

# 4. Clone the existing raw image (tpldeb.img) for new guest
virt-clone -o tpldeb -n $1 -f /virtimages/$1.img
logger -s "$PROGNAME: Cloned domain $1 to /virtimages directory"

# 5. Ajust the new generic image to become host specific

exit 0