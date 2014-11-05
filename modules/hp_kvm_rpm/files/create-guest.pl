#!/usr/bin/perl
#
# /root/bin/create-guest.pl <new_domain> <local_guest_mac> <local_guest_ip>
#
# Usage: create-guest.pl debinix-org
# Note: Original domain 'wheezy' must exist, other wise script terminates
#       Mac and IP addresses are private behind NAT (not public)
#
# Prepare a new guest image (Debian type)
#
##############################################################
# DO NOT EDIT. MANAGES BY PUPPET. CHANGES WILL BE WIPED OUT. #
##############################################################
use strict;
use warnings;
use XML::Twig;

my $original_domain_name = 'wheezy';
my $original_domain_path = "/etc/libvirt/qemu/" . $original_domain_name . ".xml" ;
##########################################
### No changes required below this line ##
##########################################

# Pre-check, does the 'original domain' exist on host
if ( ! -f $original_domain_path ) {
    print "\nMissing original guest image $original_domain_path - cannot proceed!\n";
    exit 1;
}

# Pre-check, check passedc arguments
my $num_args = $#ARGV +1 ;
if ($num_args != 3) {
print "\nUsage: create-guest.pl <new_domain> <local_mac_address> <local_ip_address>\n";
exit 1;
}

# 1. Clone the existing original image (e.g. from /var/lib/libvirt/images/wheezy.img)
my $new_domain = $ARGV[0];
my $out_image_path = "/var/lib/libvirt/images/$new_domain" . ".img";
my $new_mac = $ARGV[1];
my $new_ip = $ARGV[2];

system("virt-clone -o $original_domain_name -n $new_domain --mac $new_mac -f $out_image_path");

# 2. Update the domain configuration with ip address and mac address
my $xmlpathfile = "/etc/libvirt/qemu/" . $new_domain . ".xml" ;

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
system("virt-edit -d $new_domain /etc/network/interfaces -e 's/address 192.168.122.2/address $new_ip/'");
system("virt-edit -d $new_domain /etc/hosts -e 's/192.168.122.2/$new_ip/'");
system("virt-edit -d $new_domain /etc/hosts -e 's/$original_domain_name/$new_domain/g'");

# 4. Clean image to sane default before first use with 'virt-sysprep'
system("virt-sysprep -d $new_domain --enable udev-persistent-net,hostname,logfiles,bash-history --hostname $new_domain");

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


