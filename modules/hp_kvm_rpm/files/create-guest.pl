#!/usr/bin/perl
#
# /root/bin/create-guest.pl <new_domain> <local_guest_ip>  <local_guest_gw> <local_guest_bcst> <local_guest_netw> <new_host_name> <new_bridge>
#
# Usage: create-guest.pl debinix_org '192.168.40.40' '192.168.40.1' '192.168.40.255' 192.168.40.255' deborg virbr3 
# Note: Original domain 'wheezy' must exist, other wise script terminates
#       IP addresses are private behind NAT (not public)
#
# Purpose: Prepare a new guest image (Debian type)
# Post-install: Edit configuration filterref with correct ip address.
#               i.e. 'virsh edit <new_domain>' and add '<local_guest_ip>'
#               in <interface> filterref-section like so:
#
#    <interface type='bridge'>
#       <source bridge='<%= $nat_bridge_name %>'/>
#       <model type='virtio'/>
#       <filterref filter='clean-traffic'>
#           <parameter name='IP' value='<local_guest_ip>'/>
#       </filterref>
#    <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
#    </interface>
#
# Not easily scriptable...:-(
#
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
if ($num_args != 7) {
print "\nUsage: create-guest.pl <new_domain> <local_ip_address> <new_host_name> <new_bridge>\n";
exit 1;
}

# 1. Clone the existing original image (e.g. from /var/lib/libvirt/images/wheezy.img)
my $new_domain = $ARGV[0];
my $out_image_path = "/var/lib/libvirt/images/$new_domain" . ".img";

my $new_ip = $ARGV[1];
my $new_gw = $ARGV[2];
my $new_bcst = $ARGV[3];
my $new_net = $ARGV[4]; 

my $new_host_name = $ARGV[5];
my $new_bridge = $ARGV[6];

system("virt-clone -o $original_domain_name --mac=RANDOM -n $new_domain -f $out_image_path");

# 2. Update the domain configuration with mac and ip address
#my $xmlpathfile = "/etc/libvirt/qemu/" . $new_domain . ".xml" ;
#
#my $twig = XML::Twig->new(
#            twig_handlers => {
#                q{/domain/devices/interface/source[@bridge]} => \&set_source,                
#                q{/domain/devices/interface/filterref/parameter[@value]} => \&set_ip,    
#            },
#            pretty_print => 'indented',
#);
#$twig->parsefile_inplace( $xmlpathfile, '.tmp' );
#$twig->flush;

# 3. Clean image to sane default before first use with 'virt-sysprep'
#    Note cannot expect to set hostname (accepts only a-z) equal to new-domain name! 
system("virt-sysprep -d $new_domain --enable udev-persistent-net,hostname,logfiles,bash-history --hostname $new_host_name");

# 4. Set assigned ip address and domain name to new guest with 'virt-edit'
system("virt-edit -d $new_domain /etc/network/interfaces -e 's/address 192.168.122.2/address $new_ip/'");
system("virt-edit -d $new_domain /etc/network/interfaces -e 's/gateway 192.168.122.1/gateway $new_gw/'");
system("virt-edit -d $new_domain /etc/network/interfaces -e 's/broadcast 192.168.122.255/broadcast $new_bcst/'");
system("virt-edit -d $new_domain /etc/network/interfaces -e 's/network 192.168.122.0/network $new_net/'");

system("virt-edit -d $new_domain /etc/hosts -e 's/192.168.122.2/$new_ip/'");
system("virt-edit -d $new_domain /etc/hosts -e 's/$original_domain_name/$new_host_name/g'");

#
# ### SUBROUTINES FOR XML ###
#

#sub set_source {
#    my ($twig, $bridge) = @_;
#    $bridge->set_att( bridge => $new_bridge );
#    $twig->flush;
#}
#
#sub set_ip {
#    my ($twig, $value) = @_;
#    $value->set_att( value => $new_ip );
#    $twig->flush;
#}


