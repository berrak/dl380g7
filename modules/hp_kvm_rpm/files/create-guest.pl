#!/usr/bin/perl
#
# /root/bin/create-guest.pl <domain>
# 
# Create new guest from xml template
#
##############################################################
# DO NOT EDIT. MANAGES BY PUPPET. CHANGES WILL BE WIPED OUT. #
##############################################################
use strict;
use warnings;

my $num_args = $#ARGV +1 ;

if ($num_args != 1) {
    print "\nUsage: create-guest.pl <domain>\n";
    exit 1;
}

my $domain = $ARGV[0];
my $xmlfile = $domain . ".xml";
my $xmlpath = "/etc/libvirt/qemu/$xmlfile";
my $imagepath = "/virtimages/$domain" . ".img";
my $is_defined = `virsh list --all | grep $domain`;

# 1. Register the new guest xml-file for the new domain

if (!$is_defined) {
    system ("virsh define $xmlpath");
}

# 2. Clone the existing debian 7 raw image (from /var/lib/libvirt/images/tpldeb.img)
system("virt-clone -o tpldeb -n $domain -f $imagepath");

# 3. Manipulate the cloned image before first use
