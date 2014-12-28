#!/usr/bin/perl
##############################################################
# DO NOT EDIT. MANAGED BY PUPPET. CHANGES WILL BE WIPED OUT. #
##############################################################
# /root/bin/puppetize-guest.pl
#
# Usage:   # scp puppetize-guest.pl <hostip>:/usr/local/bin/puppetize-guest.pl
#          # ssh root@<hostip> or 'virsh console <name>'
#          # puppetize-guest.pl puppetmaster-ipaddress { wheezy | oracle-6 } 
# 
# Purpose: Install latest puppet agent from puppetlabs on (virtual) node.
#
#          NOTE Used both for Debian wheezy and OracleLinux 6 guests.
#
# Exit codes: Exit with non-zero code if errors
#
# Log: Appends logger information to /var/log/perl.log
#
# Pre-install on host:
#
#   (1) Create the node in host 'site'pp' manifest
#
# Here, the script 'install' step comprise of following:
#
#   a) add puppetlabs repository information to guest linux distribution
#   b) update local repository information
#   c) installs 'puppet' (i.e. puppet agent)
#   d) configure puppet agents configuration file for the initial run
#   e) adds puppetmaster ip address to node 'hosts' file
#
# Post-install on node: Logg into node and manually run:
#
#   (2) execute on node: # puppet agent --onetime --no-daemonize --verbose --waitforcert 60
#
# Post-install on host: Exit to host and manually run:
#
#   (3) sign the certificate request on host: # puppet cert --sign <host-fqdn>
#      (and with that the first puppet agent run is executed)
#
################################################################

use 5.010;
use strict;
use warnings;
use Log::Log4perl;
use English;
use File::Basename qw( basename );
use Net::Domain qw(hostname hostdomain);


our $VERSION = '0.06';
our $FALSE = 0;
our $OK = 0;

############################
#     GLOBAL VARIABLES     #
############################

our $our_logger;
our $our_script ;
our $our_main_error_flag ;

############################
# MAIN PROGRAM STARTS HERE #
############################

my ( $puppetmaster_ip, $linux_distribution ) = init(\@ARGV);

if ( $our_main_error_flag == $OK ) {
    
    # download to /tmp
    my $has_changed_directory = chdir( '/tmp' ) ;
    if ( $has_changed_directory == $FALSE ) {
        $our_main_error_flag = 1;
    }

    if ( $our_main_error_flag == $OK ) {    
        get_puppet_repository_information($linux_distribution);
    }
    
    if ( $our_main_error_flag == $OK ) {  
        install_puppet_agent($linux_distribution);
    }

    if ( $our_main_error_flag == $OK ) { 
        configure_puppet_agent($linux_distribution);    
    }
    
    if ( $our_main_error_flag == $OK ) {     
        update_local_hosts_file( $puppetmaster_ip );
    }
} 

prepare_exit($our_main_error_flag);
exit ($our_main_error_flag);

############################
#    MAIN-SUBROUTINES      #
############################
#
# Usage     : get_puppet_repository_information($linux_distribution)
# Arguments : $linux_distribution - target linux distribution (*.deb or *.rpm)
# Purpose   : Download puppetlabs package to add repository info to target node
# Returns   : Returns to caller with 0 or non-zero error code
# Throws    : No
#

sub get_puppet_repository_information {
    
    my $pkg = shift;
    $our_logger->debug("get_puppet_repository_information($pkg)");
    my $exitvalue;
    my $exitsignal;
    my $myurl="";
 
    # build puppetlabs url for apt repository update package
    if ( $pkg eq 'wheezy.deb' ) {
        $myurl = "http://apt.puppetlabs.com/puppetlabs-release-" . $pkg;

        system("wget $myurl");
        $exitvalue = $? >> 8;
        $exitsignal = $? & 127;
        
        if ($? == -1) {
            $our_logger->error("wget failed to execute: $!");            
            $our_main_error_flag = 1;
        }
        elsif ( $exitsignal ) {
            $our_logger->error("wget died with signal: $exitsignal");            
            $our_main_error_flag = $exitsignal;
        }
        else {
            $our_logger->debug("wget exited with value: $exitvalue");
            $our_main_error_flag = $exitvalue;
        }
        
    }
    
    # build puppetlabs url for rpm repository update package
    elsif ( $pkg eq 'el-6.noarch.rpm' ) {
        $myurl = "http://yum.puppetlabs.com/puppetlabs-release-" . $pkg;

        system("wget $myurl");
        $exitvalue = $? >> 8;
        $exitsignal = $? & 127;     
        
        if ($? == -1) {
            $our_logger->error("wget failed to execute: $!");            
            $our_main_error_flag = 1;
        }
        elsif ( $exitsignal ) {
            $our_logger->error("wget died with signal: $exitsignal");            
            $our_main_error_flag = $exitsignal;
        }
        else {
            $our_logger->debug("wget exited with value: $exitvalue");
            $our_main_error_flag = $exitvalue;
        }
        
    } else { 

        $our_logger->error("Unknown distribution: ($myurl)");      
        $our_main_error_flag = 1; 
    }
    
}

#
# Usage     : install_puppet_agent($linux_distribution)
# Arguments : $linux_distribution - target linux distribution (*.deb or *.rpm)
# Purpose   : Install puppet agent target node
# Returns   : Returns to caller with 0 or non-zero error code
# Throws    : No
#
sub install_puppet_agent {
    
    my $pkg = shift;
    $our_logger->debug("install_puppet_agent($pkg)");
    my $exitvalue;
    my $exitsignal;
    
    # update sources
    if ( $pkg eq 'wheezy.deb' ) {
        my $dpkg_arg = "puppetlabs-release-" . $pkg;

        system("dpkg -i /tmp/$dpkg_arg");
        $exitvalue = $? >> 8;
        $exitsignal = $? & 127;
        
        if ($? == -1) {
            $our_logger->error("dpkg failed to execute: $!");            
            $our_main_error_flag = 1;
        }
        elsif ( $exitsignal ) {
            $our_logger->error("dpkg died with signal: $exitsignal");            
            $our_main_error_flag = $exitsignal;
        }
        else {
            $our_logger->debug("dpkg exited with value: $exitvalue");
            $our_main_error_flag = $exitvalue;
        }
        
        # install debian puppet agent
        if ( $our_main_error_flag == $OK ) {
            
            system("aptitude update && aptitude -y install puppet");
            $exitvalue = $? >> 8;
            $exitsignal = $? & 127;
            
            if ($? == -1) {
                $our_logger->error("aptitude failed to execute: $!");            
                $our_main_error_flag = 1;
            }
            elsif ( $exitsignal ) {
                $our_logger->error("aptitude died with signal: $exitsignal");            
                $our_main_error_flag = $exitsignal;
            }
            else {
                $our_logger->debug("aptitude exited with value: $exitvalue");
                $our_main_error_flag = $exitvalue;
            }
            
        }
    }
        
    # install rpm puppet agent package
    elsif ( $pkg eq 'el-6-noarch.rpm' ) {

        system("yum install puppet");
        $exitvalue = $? >> 8;
        $exitsignal = $? & 127;     
        
        if ($? == -1) {
            $our_logger->error("yum install puppet failed to execute: $!");            
            $our_main_error_flag = 1;
        }
        elsif ( $exitsignal ) {
            $our_logger->error("yum install puppet died with signal: $exitsignal");            
            $our_main_error_flag = $exitsignal;
        }
        else {
            $our_logger->debug("yum install puppet exited with value: $exitvalue");
            $our_main_error_flag = $exitvalue;
        }
    
    } else { 

        $our_logger->error("Unknown distribution: $pkg");      
        $our_main_error_flag = 1; 
    }
     
}

#
# Usage     : configure_puppet_agent()
# Arguments : N/A
# Purpose   : Replace default puppet.conf (same for all dists)
# Returns   : Returns to caller with 0 or non-zero error code
# Throws    : No
# Caveats   : Assumes puppetmaster and node is on same domain (network)
#
sub configure_puppet_agent {
    
    my $puppet_conf;
    my $nodehost = hostname();
    my $nodedomain = hostdomain();
    my $puppetconfpath = "/etc/puppet/puppet.conf";
  
    # Replace default puppet.conf with above
    if ( open my $fh, '>', $puppetconfpath ) {

        print $fh <<EOF;
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
server=puppet.$nodedomain
[agent]
certname=$nodehost.$nodedomain
EOF
        close $fh;
        $our_main_error_flag = $OK;  

    } else {
        
        $our_logger->error("Failed to replace $puppetconfpath");      
        $our_main_error_flag = 1;
    }    
     
}

#
# Usage     : update_local_hosts_file($puppetmaster_ip)
# Arguments : $puppetmaster_ip - ip address of puppetmaster
# Purpose   : Appends puppetmaster ipadress/domain to /etc/hosts
# Returns   : Normally returns to caller with 0 or non-zero error code
# Throws    : No
# Caveats   : Assumes puppetmaster and node is on same domain (network)
#
sub update_local_hosts_file {
 
    my $master_ip = shift @_;
    my $nodedomain = hostdomain();
    
    # Append ip-address and puppetserver host information to node hosts file
    if ( system("echo $master_ip puppet.$nodedomain puppet >> /etc/hosts") != $OK ) {
        $our_logger->error("Failed to append $master_ip puppet.$nodedomain puppet to /etc/hosts");      
        $our_main_error_flag = 1;         
    } else {
        $our_main_error_flag = $OK;         
    }

}


############################
#  INIT- AND FINISH SUBS   #
############################
#
# Usage     : init(\@ARGV)
# Arguments : Ref to @ARGV -- command line list
# Purpose   : Initilize logger and validate cli input
# Returns   : Normally returns to caller with 0
#             or with exit code 1 on error.
# Throws    : No
#
sub init {
    
    my $ref_argv = shift @_;
    my $num_args = scalar @$ref_argv ;
    my $puppet_master_ip ;
    my $linux_dist ; 
    my $init_error_flag = $FALSE;
    

    
    # initilize globals
    $our_main_error_flag = $FALSE;
    $our_script = basename($0);
    
    # script must run as root
    if ( $EFFECTIVE_USER_ID != 0 ) {
        die "Script $our_script must run as root - Aborting...";
    }
    
    # install if missing perl library - Needs rewrite!
    ## required for logging function
    #my $log4perl_pkg = 'liblog-log4perl-perl';
    #system("dpkg -s $log4perl_pkg 2>/dev/null >/dev/null || aptitude -y install $log4perl_pkg");
    
    # initilize logger
    my $log_conf = q(
        log4perl.rootLogger              = DEBUG, LOG1
        log4perl.appender.LOG1           = Log::Log4perl::Appender::File
        log4perl.appender.LOG1.filename  = /var/log/perl.log
        log4perl.appender.LOG1.mode      = append
        log4perl.appender.LOG1.layout    = Log::Log4perl::Layout::PatternLayout
        log4perl.appender.LOG1.layout.ConversionPattern = %d %p %F %m %n   
    );
    Log::Log4perl::init(\$log_conf);
    $our_logger = Log::Log4perl->get_logger();
    
    $our_logger->info("------------ New Logger Initilized ------------ ");
    
    # validate input argument numbers
    if ($num_args != 2) {
        $our_logger->error("Wrong number of arguments ($num_args) passed to $our_script");
        $init_error_flag = 1;
    } else {
        $puppet_master_ip = $ref_argv->[0] ;
        $linux_dist = $ref_argv->[1] ; 
         
        # validate
        if ( $linux_dist eq "wheezy" ) {
            $linux_dist = 'wheezy.deb';
            
        } elsif ( $linux_dist eq "oracle-6" ) {
            $linux_dist = 'el-6-noarch.rpm';
            
        } else {
            $our_logger->error("Unknown linux distribution ($linux_dist) passed to $our_script");
            $init_error_flag = 2;      
        
        }
    }
    
    # assign current status to global exit code after initialization
    $our_main_error_flag = $init_error_flag;
     
    return( $puppet_master_ip, $linux_dist );
}
#
# Usage     : prepare_exit()
# Arguments : N/A
# Purpose   : Write main exit code to logger
# Returns   : Returns to caller with 0
# Throws    : No
#

sub prepare_exit {
      
    $our_logger->info("Logger closed - processing finished with exit code: $our_main_error_flag");  
    
}

