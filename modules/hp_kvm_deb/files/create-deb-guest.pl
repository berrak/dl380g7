#!/usr/bin/perl
#
# /root/bin/create-guest.pl
#
# Usage: create-deb-guest.pl trise '192.168.0.1' '192.168.0.41' '52:54:00:00:00:41' '192.168.0.255' 192.168.0.0' trise kvmbr0 
# Note: Original domain 'wheezy' must exist, other wise script terminates
#       IP addresses are public
#
# Purpose: Prepare a new guest image (Debian type)
#
##############################################################
# DO NOT EDIT. MANAGES BY PUPPET. CHANGES WILL BE WIPED OUT. #
##############################################################
use strict;
use warnings;
use XML::Twig;
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($INFO);

my $original_domain_name = 'wheezy';
my $original_domain_path = "/etc/libvirt/qemu/" . $original_domain_name . ".xml" ;
##########################################
### No changes required below this line ##
##########################################

# Pre-check, does the 'original domain' exist on host
if ( ! -f $original_domain_path ) {
    ERROR "\nMissing original guest image $original_domain_path - cannot proceed!\n";
    exit 1;
}

# Pre-check, check passed arguments
my $num_args = $#ARGV +1 ;
if ($num_args != 8) {
print "\nUsage: create-deb-guest.pl <new_domain> <local_gw_address> <local_ip_address> <local_mac_address> <new_broadcast> <new_network> <new_host_name> <new_bridge>\n";
ERROR "Wrong number of arguments ($num_args) passed to create-deb-guest.pl";
exit 2;
}

# 1. Clone the existing original image (e.g. from /data/vm-images/wheezy.img)
my $new_domain = $ARGV[0];
my $out_image_path = "/data/vm-images/$new_domain" . ".img";

my $new_gw = $ARGV[1];
my $new_ip = $ARGV[2];
my $new_mac = $ARGV[3];
my $new_bcst = $ARGV[4];
my $new_net = $ARGV[5]; 

my $new_host_name = $ARGV[6];
my $new_bridge = $ARGV[7];

INFO "virt-clone -o $original_domain_name --mac=$new_mac -n $new_domain -f $out_image_path";
system("virt-clone -o $original_domain_name --mac=$new_mac -n $new_domain -f $out_image_path");

# 2. Update the domain configuration with new mac address
my $xmlpathfile = "/etc/libvirt/qemu/" . $new_domain . ".xml" ;

my $twig = XML::Twig->new(
            twig_handlers => {
                q{/domain/devices/interface/mac[@address]} => \&set_mac,                  
            },
            pretty_print => 'indented',
);
$twig->parsefile_inplace( $xmlpathfile, '.tmp' );
$twig->flush;

INFO "Twig done with XML-processing of $xmlpathfile";

# 3. Clean new image to sane default before first use with 'virt-sysprep'
#    Note cannot expect to set hostname (accepts only a-z) equal to new-domain name!

INFO "virt-sysprep -d $new_domain --enable udev-persistent-net,hostname,logfiles,bash-history --hostname $new_host_name";
system("virt-sysprep -d $new_domain --enable udev-persistent-net,hostname,logfiles,bash-history --hostname $new_host_name");

# 4. Set assigned ip address and domain name to new guest with 'virt-edit'
system("virt-edit -d $new_domain /etc/network/interfaces -e 's/address 192.168.0.40/address $new_ip/'");
system("virt-edit -d $new_domain /etc/network/interfaces -e 's/gateway 192.168.0.1/gateway $new_gw/'");
system("virt-edit -d $new_domain /etc/network/interfaces -e 's/broadcast 192.168.0.255/broadcast $new_bcst/'");
system("virt-edit -d $new_domain /etc/network/interfaces -e 's/network 192.168.0.0/network $new_net/'");

system("virt-edit -d $new_domain /etc/hosts -e 's/192.168.0.40/$new_ip/'");
system("virt-edit -d $new_domain /etc/hosts -e 's/$original_domain_name/$new_host_name/g'");
INFO "virt-edit done of domain $new_domain";

 ### SUBROUTINE FOR XML ###

sub set_mac {
    my ($twig, $address) = @_;
    $address->set_att( address => $new_mac );
    $twig->flush;
}

