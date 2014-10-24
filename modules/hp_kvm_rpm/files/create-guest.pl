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
use XML::Twig;

my $newuuid = `uuidgen`;
my $num_args = $#ARGV +1 ;

if ($num_args != 1) {
    print "\nUsage: create-guest.pl <domain>\n";
    exit 1;
}

my $domain = $ARGV[0];
my $xmlfile = $domain . ".xml";
my $xmlpath = "/etc/libvirt/qemu/$xmlfile";

# 1. Undefine domain, if existing
system ("virsh undefine $domain");

# 2. Replace the old uuid in the new guest domain xml-file
XML::Twig->new(
    
    pretty_print  => 'indented',
    twig_handlers => { 
        uuid => sub { 
            $_->set_text( $newuuid )->flush
        },
    },
)->parsefile_inplace($xmlpath, 'tmp');

# 3. Register the new guest xml-file for the new domain
system ("virsh define $xmlpath");

# 4. Clone the existing raw image (from tpldeb.img) for the new guest
my $imagepath = "/virtimages/$domain" . ".img";
system("virt-clone -o tpldeb -n $domain -f $imagepath");

# 5. Manipulate cloned image before first use
