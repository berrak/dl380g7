#!/usr/bin/perl
#
# /root/bin/create-guest.pl <domain>
#
# Prepare a new guest image (Debian type)
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
my $out_image_path = "/var/lib/libvirt/images/$domain" . ".img";

# 1. Clone the existing raw image (from /var/lib/libvirt/images/tpldeb.img)
system("virt-clone -o tpldeb -n $domain -f $out_image_path");


# 2. Update the domain configuration with ip address and mac address
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

# 3. Set assigned ip address to new guest with 'virt-edit'
system("virt-edit -d $domain /etc/network/interfaces -e 's/192.168.122.2/$new_ip/'");
system("virt-edit -d $domain /etc/hosts -e 's/192.168.122.2/$new_ip/'");

# 4. Clean image to sane default before first use with 'virt-sysprep'
system("virt-sysprep -d $domain --enable udev-persistent-net,hostname --hostname $domain");

#
# ### SUBROUTINES FOR XML ###
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


