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
my $imagepath = "/virtimages/$domain" . ".img";

# 1. Clone the existing raw image (from /var/lib/libvirt/images/tpldeb.img)
system("virt-clone -o tpldeb -n $domain -f $imagepath");

# 2. Manipulate the cloned image before first use
