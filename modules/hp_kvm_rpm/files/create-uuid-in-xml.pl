#!/usr/bin/perl
#
# /root/bin/create-uuid-in-xml.pl <domain>
# 
# Create uuid and place the element in XMl file of VM definition
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
    print "\nUsage: change-uuid-in-xml.pl <domain>\n";
    exit 1;
}

my $xmlfile = $ARGV[0];

XML::Twig->new(
    
    pretty_print  => 'indented',
    twig_handlers => { 
        uuid => sub { 
            $_->set_text( $newuuid )->flush
        },
    },
)->parsefile_inplace( $xmlfile, 'tmp_*' );
