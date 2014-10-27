#!/usr/bin/perl
#
# /root/bin/create-guest.pl <domain>
#
# Replace some attributes in file
#
##############################################################
# DO NOT EDIT. MANAGES BY PUPPET. CHANGES WILL BE WIPED OUT. #
##############################################################
use strict;
use warnings;
use XML::Twig;

my $num_args = $#ARGV +1 ;
if ($num_args != 3) {
print "\nUsage: twigit.pl <domain> <mac-address> <ip-address>\n";
exit 1;
}
my $domain = $ARGV[0];
my $out_image_path = "/virtimages/$domain" . ".img";

# 1. Clone the existing raw image (from /var/lib/libvirt/images/tpldeb.img)
system("virt-clone -o tpldeb -n $domain -f $out_image_path");


# 2. Update the domain definition with ip address and mac address

my $xmlfile = $domain . ".xml";
my $xmlpathfile = "/etc/libvirt/qemu/" . $xmlfile ;

my $new_mac = $ARGV[1];
my $new_ip = $ARGV[2];

my $twig = XML::Twig->new(
            twig_handlers => {
                q{/domain/devices/interface/mac[@address]} => \&set_mac,
                q{/domain/devices/interface/filterref/parameter[@value]} => \&set_ip,
            },
            pretty_print => 'indented',
);


$twig->parsefile_inplace( $xmlpathfile, '.tmp' );
$twig->flush;

# 3. Manipulate the cloned image before first use

# TODO

#
# ### SUBROUTINES ###
#
sub set_mac {
    my ($twig, $mac) = @_;
    $mac->set_att( address => $new_mac );
    $twig->flush;
}

sub set_ip {
    my ($twig, $value) = @_;
    $value->set_att( value => $new_ip );
    $twig->flush;
}


