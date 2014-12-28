#
## site.pp (Tested dists: Debian 7.X, OracleLinux 6.X)
#
$extlookup_precedence = ["fstab_sda1_uuid"]
$extlookup_datadir = "/etc/puppet/files"

## Development server, Oracle Linux 6.5
node 'ol65.home.tld' {

    ## BASIC
    
    # Enable dnsmasq for DNS
    class { hp_dnsmasq::config :
				primary_interface => 'eth0',
                ispdns1 => '208.67.222.222',
                ispdns2 => '208.67.220.220',
                srv_hostname => 'ol65',
				srv_domain => 'home.tld',
    }
    
    # above DNS must resolv before 'hp_pupetize'. Note that 'puppet-server'
    # host will be named 'puppet'. Oracle use latest puppet-server 3.7
    include hp_puppetize
    include puppet_utils
    
    # primary host networking configuration (generate uuid with 'uuidgen')
    hp_network_rpm::config { 'eth0'  :
                ip => '192.168.0.66',
                prefix => '24',
                uuid => '8f83faf4-4ac3-4211-8616-1a87c6244039',
                gateway => '192.168.0.1',
                broadcast => '192.168.0.255',
                ispdns1 => '208.67.222.222',
                ispdns2 => '208.67.220.220',
    }
    
    # install KVM virtualization packages (and set 'default' network)
    # dhcp server with 5 PRIVATE IPs: 192.168.122.40 -- 192.168.122.44 and
    # corresponding 5 macs: 52:54:00:00:00:40 -- 52:54:00:00:00:44'
    # also contains name i.e. FQDN for each LXC for above IPs.
    class { hp_kvm_rpm::config : natnet_default_active => 'true' }   
    
    # on host, virtual network aliases PUBLIC interfaces for LXC
    hp_network_rpm::alias { 'eth0:0' : public_guest_ip => '192.168.0.40', prefix => '24', onboot => 'yes' }    
    hp_network_rpm::alias { 'eth0:1' : public_guest_ip => '192.168.0.41', prefix => '24', onboot => 'yes' }
    hp_network_rpm::alias { 'eth0:2' : public_guest_ip => '192.168.0.42', prefix => '24', onboot => 'yes' }
    hp_network_rpm::alias { 'eth0:3' : public_guest_ip => '192.168.0.43', prefix => '24', onboot => 'yes' }
    hp_network_rpm::alias { 'eth0:4' : public_guest_ip => '192.168.0.44', prefix => '24', onboot => 'yes' } 
    
    # install LXC packages
    include hp_lxc_rpm
    
    # Configure initial OracleLinux EL6 container (all use libvirt 'default' net)
    # NOTE: Create container first: 'xlc-create -n <cont_name> -t oracle -- --release=6.latest'
    # NOTE: IP address and domain is used to update /etc/hosts-file in conatainer
    # NOTE: MAC address and libvirt 'default' net and DHCP defines the container (fixed) IP
    hp_lxc_rpm::add_container_config { 'deborg' :
                               cont_private_mac_addr => '52:54:00:00:00:40',
                               cont_private_ip_addr => '192.168.122.40',
                               cont_domain_name => 'lxc.tld',
    }
    
    hp_lxc_rpm::add_container_config { 'trise' :
                               cont_private_mac_addr => '52:54:00:00:00:41',
                               cont_private_ip_addr => '192.168.122.41',
                               cont_domain_name => 'lxc.tld',                               
    }
                               
    hp_lxc_rpm::add_container_config { 'mc' :
                               cont_private_mac_addr => '52:54:00:00:00:42',
                               cont_private_ip_addr => '192.168.122.42',
                               cont_domain_name => 'lxc.tld',                               
    }
                               
    hp_lxc_rpm::add_container_config { 'kronlund' :
                               cont_private_mac_addr => '52:54:00:00:00:43',
                               cont_private_ip_addr => '192.168.122.43',
                               cont_domain_name => 'lxc.tld',                               
    }
                               
    hp_lxc_rpm::add_container_config { 'git' :
                               cont_private_mac_addr => '52:54:00:00:00:44',
                               cont_private_ip_addr => '192.168.122.44',
                               cont_domain_name => 'lxc.tld',                               
    }
    
    # temporary skip fstab final entry
    #class { hp_fstab::config : fstabhost => 'ol65' }
    
    # This is the ntp server for localnet
    class { hp_ntp : role => 'lanserver', peerntpip => '192.168.0.66' }
    include hp_smartmontools
    
    ## USER PROFILES (note e.g. user 'bekr' must first exist!)
    
    include hp_root_home
    include hp_root_bashrc
    # add local users
    hp_user_bashrc::config { 'bekr' : }

    
    ## APPLICATIONS
	# Install REDHAT packages without any special configurations
    class { hp_install_rpms : rpms => [ "yum-plugin-priorities", "tree", "ethtool", "parted", "lsof", "curl" ] }
    
    
    ## SECURITY
    hp_selinux::state { 'enforcing' : }
    hp_sudo::config { 'bekr': }
    include hp_logwatch
    include hp_iptables_rpm
    
    # Enable mac filtering but no custom rules yet - libvirt adds own chains
    include hp_ebtables_rpm    
    
    # disable unnecessary services
    hp_service::disable { 'atd' : }
    hp_service::disable { 'autofs' : }
    hp_service::disable { 'kdump' : }
    hp_service::disable { 'rhnsd' : }
    hp_service::disable { 'mdmonitor' : }  
    hp_service::disable { 'portreserve' : }
    
    # remove these, for a server unnecessary REDHAT packages
    class { hp_remove_rpms : rpms => [ "cups" ] }
    
    
    ## MAINTENANCE
	include hp_ssh_server
    hp_ssh_server::sshuser { 'bekr' : }
    include hp_auto_upgrade
    include hp_logrotate
    include hp_rsyslog

}

########################################################################

## Virtual try-out guest, Debian 7 (wheezy) - 192.168.122.122
node 'wheezy.vm.tld' {

	## BASIC
	
	# Puppet helper routines
    include puppet_utils
	# Manage puppet itself
    include hp_puppetize

	# Configure APT
    include hp_apt_config
    
	# hosts and fstab files
	class { hp_hosts::config : puppetserver_hostname => 'puppet' }
	# class { hp_fstab::config : fstabhost => 'wheezy' }

	## USER PROFILES ##
	
	# Set up root's home directories and bash customization
    include hp_root_home
    include hp_root_bashrc

	## APPLICATIONS ##
    
	# DEBIAN packages without any special configurations
    class { hp_install_debs : debs => [ "tree", "sipcalc", "gddrescue", "lshw",
	       "bind9-host", "lynis", "pydf" , "dnsutils" , "ethtool", "parted", "lsof", "curl" ] }
    
    # APACHE2 (prefork)
    include hp_apache2
    
	## Define a new VM's Apache2 site - transparent proxy in host
    hp_apache2::vhost { 'deborg.debinix.org' :
            priority => '001',
          devgroupid => 'root',
          execscript => 'none',
                port => '80',
    }    
    
	## SECURITY

    # Automatic security upgrades with cron script
	include hp_auto_upgrade
    
    
    ## MAINTENANCE

}


########################################################################

## LXC container try-out, OracleLinux (EL6.6) - 192.168.122.40
node 'deborg.lxc.tld' {

	## BASIC
	
	# Puppet helper routines
    include puppet_utils
	# Manage puppet itself
    include hp_puppetize
    
    # gateway is primary DNS (virbr0 runs dnsmasq service)
    class { hp_lxc_resolvconf_rpm::config :
                        lxcdomain => 'lxc.tld',
                             dns1 => '192.168.122.1',
                             dns2 => '208.67.222.222',
                             dns3 => '208.67.220.220',                
    }


    ## USER PROFILES (note e.g. user 'bekr' must first exist!)
    
    include hp_root_home
    include hp_root_bashrc
    # add local users
    hp_user_bashrc::config { 'bekr' : }

    ## APPLICATIONS
	# Install REDHAT packages without any special configurations
    class { hp_install_rpms : rpms => [ "tree", "nano", "nmap", "curl", "bind-utils" ] }
    
    include hp_apache2_rpm

    ## MAINTENANCE
	include hp_ssh_server
    hp_ssh_server::sshuser { 'bekr' : }

}

########################################################################

## LXC container try-out, OracleLinux (EL6.6) - 192.168.122.41
node 'trise.lxc.tld' {

	## BASIC
	
	# Puppet helper routines
    include puppet_utils
	# Manage puppet itself
    include hp_puppetize

    # gateway is primary DNS (virbr0 runs dnsmasq service)
    class { hp_lxc_resolvconf_rpm::config :
                        lxcdomain => 'lxc.tld',
                             dns1 => '192.168.122.1',
                             dns2 => '208.67.222.222',
                             dns3 => '208.67.220.220',                
    }

    ## USER PROFILES (note e.g. user 'bekr' must first exist!)
    
    include hp_root_home
    include hp_root_bashrc
    # add local users
    hp_user_bashrc::config { 'bekr' : }

    ## APPLICATIONS
	# Install REDHAT packages without any special configurations
    class { hp_install_rpms : rpms => [ "tree", "nano", "nmap", "curl", "bind-utils" ] }

    include hp_apache2_rpm

    ## MAINTENANCE


}

########################################################################

## Development server, Debian 7 (wheezy)
node 'node-hphome.home.tld' {

	## BASIC
	
	# Puppet helper routines
    include puppet_utils
	# Manage puppet itself
    include hp_puppetize
	
	# Configure APT
    include hp_apt_config
	
	# Add 'testing' for very few exceptional debian non-binary package cases
	hp_apt_add_release::config { 'testing' : pin_priority => '90' }

	# Prefer latest 'lynis/testing' package over stable
	hp_apt_pin_pkg::config { 'lynis' : pin_priority => '995', release => 'testing' }	
		
	# Lan ntp server provids time services to all lan clients
    class { 'hp_ntp' : role => 'lanserver', peerntpip => '192.168.0.12' }

	# hosts and fstab files
	class { hp_hosts::config : puppetserver_hostname => 'hphome' }
	class { hp_fstab::config : fstabhost => 'hphome' }
		
	
	## USER PROFILES ##
	
	# Set up root's home directories and bash customization
    include hp_root_home
    include hp_root_bashrc
	
	# Set up user's home directories and bash customization
    hp_user_bashrc::config { 'bekr' : }
	hp_sudo::config { 'bekr': }
	hp_mutt::install { 'bekr': mailserver_hostname => 'hphome' }
	
	
	## APPLICATIONS ##
	
	# DEBIAN packages without any special configurations
    class { hp_install_debs : debs => [ "tree", "sipcalc", "gddrescue", "lshw",
	       "bind9-host", "lynis", "pydf" , "dnsutils" , "ethtool", "parted", "lsof", "curl" ] }
	
	# MAIL server (relay external mails via google smtp)
	hp_postfix::install { 'mta' :
			            ensure => 'installed',
			install_cyrus_sasl => 'true',
			          mta_type => 'server',
		 server_root_mail_user => 'bekr',
	external_root_gmail_cc => 'bertil.kronlund',
		   smtp_relayhost_fqdn => 'smtp.gmail.com',
		  no_lan_outbound_mail => 'false',
	}
	
    # APACHE2 prefork
    include hp_apache2 
		
	## Define a new Apache2 virtual host (docroot directory writable by group 'root')
    hp_apache2::vhost { 'hphome.home.tld' :
            priority => '001',
          devgroupid => 'root',
          execscript => 'none',
    }
	

	## SECURITY

	## Add mod-security for Apache (+ module headers)
	hp_apache2::module { 'mod-security' : }
	hp_apache2::module { 'headers' : }		
	
	# Security (iptables + fail2ban)
	# fail2ban ssh is enabled. disabled apache, modsec, postfix actions
	# latter parameters needs both apache and mod-security installed
    class { hp_iptables_fail2ban::config :
		 puppetserver_hostname => 'hphome',
		   fail2ban_trusted_ip => '192.168.0.0/24',
		       fail2ban_apache => 'true',
		       fail2ban_modsec => 'true',
			  fail2ban_postfix => 'true',
	}
    # Automatic security upgrades with cron script
	include hp_auto_upgrade
	
	# Disable ipv6 in kernel/grub and use the more text lines in console mode	
    class { hp_grub::install : defaultline => 'vga=791', appendline => 'true', ipv6 => 'false' }
	
	include hp_chkrootkit
	include hp_hardening
	include hp_sysctl
    include hp_logwatch
	

	## MAINTENANCE
	
	# SSH server
	include hp_ssh_server
	
	
    # Remote log disabled in rsyslog config due to amount of traffic!
	include hp_rsyslog
	include hp_logrotate
	
	include hp_screen
	
}
########################################################################

## Original Debian wheezy based server
node 'node-dl380g7.home.tld' {

	## BASIC
	
	# Puppet helper routines
    include puppet_utils
	# Manage puppet itself
    include hp_puppetize
	
	# Configure APT
    include hp_apt_config
	
	# Add 'testing' for very few exceptional debian non-binary package cases
	hp_apt_add_release::config { 'testing' : pin_priority => '90' }

	# Prefer latest 'lynis/testing' package over stable
	hp_apt_pin_pkg::config { 'lynis' : pin_priority => '995', release => 'testing' }	
		
	# Lan ntp server provids time services to all lan clients
    class { 'hp_ntp' : role => 'lanserver', peerntpip => '192.168.0.111' }

	# hosts and fstab files
	class { hp_hosts::config : puppetserver_hostname => 'dl380g7' }
	class { hp_fstab::config : fstabhost => 'dl380g7' }
		
	
	## USER PROFILES ##
	
	# Set up root's home directories and bash customization
    include hp_root_home
    include hp_root_bashrc
	
	# Set up user's home directories and bash customization
    hp_user_bashrc::config { 'bekr' : }
	hp_sudo::config { 'bekr': }
	hp_mutt::install { 'bekr': mailserver_hostname => 'dl380g7' }
	
		
	## APPLICATIONS ##
	
	# DEBIAN packages without any special configurations
    class { hp_install_debs : debs => [ "tree", "sipcalc", "gddrescue", "lshw",
	    "bind9-host", "lynis", "pydf" , "dnsutils" , "ethtool", "parted", "lsof" ] }
	
	# MAIL server (relay external mails via google smtp)
	hp_postfix::install { 'mta' :
			            ensure => 'installed',
			install_cyrus_sasl => 'true',
			          mta_type => 'server',
		 server_root_mail_user => 'bekr',
	external_root_gmail_cc => 'bertil.kronlund',
		   smtp_relayhost_fqdn => 'smtp.gmail.com',
		  no_lan_outbound_mail => 'false',
	}
	
    # APACHE2 prefork
    include hp_apache2 
		
	## Define a new Apache2 virtual host (docroot directory writable by group 'root')
    hp_apache2::vhost { 'dl380g7.home.tld' :
            priority => '001',
          devgroupid => 'root',
          execscript => 'none',
    }
	

	## SECURITY

	## Add mod-security for Apache (+ module headers)
	hp_apache2::module { 'mod-security' : }
	hp_apache2::module { 'headers' : }		
	
	# Security (iptables + fail2ban)
	# fail2ban ssh is enabled. disabled apache, modsec, postfix actions
	# latter parameters needs both apache and mod-security installed
    class { hp_iptables_fail2ban::config :
		 puppetserver_hostname => 'dl380g7',
		   fail2ban_trusted_ip => '192.168.0.0/24  81.237.0.0/16',
		       fail2ban_apache => 'true',
		       fail2ban_modsec => 'true',
			  fail2ban_postfix => 'true',
	}
    # Automatic security upgrades with cron script
	include hp_auto_upgrade
	
	# Disable ipv6 in kernel/grub and use the more text lines in console mode	
###    class { hp_grub::install : defaultline => 'vga=791', appendline => 'true', ipv6 => 'false' }
	
	include hp_chkrootkit
	include hp_hardening
	include hp_sysctl
	

	## MAINTENANCE
	
	include hp_ssh_server
	
	include hp_logwatch

    # Remote log disabled in rsyslog config due to amount of traffic!
    include hp_rsyslog
    include hp_logrotate
	
    include hp_screen

}

########################################################################

## NEW development server, Debian 7 (wheezy) puppetmaster 3.7.X
node 'hp.home.tld' {

	## BASIC
    
    # Enable dnsmasq for DNS (note use the enslaved interface - since auto-stared at boot)
    class { hp_dnsmasq::config :
				primary_interface => 'kvmbr0',
                ispdns1 => '208.67.222.222',
                ispdns2 => '208.67.220.220',
                srv_hostname => 'hp',
				srv_domain => 'home.tld',
    }	

    # above DNS must resolv before 'hp_pupetize'. Note that 'puppetmaster'. The host
    # will be named 'puppet'. Here use latest puppet version 3.7 (not Debian default)
	
    # Puppet helper routines
    include puppet_utils
	# Manage puppet itself
    include hp_puppetize
    
    # configure bridge with enslaved eth1 interface
    hp_network_deb::config { 'kvmbr0'  :
                ip => '192.168.0.66',
           netmask => '255.255.255.0',
		   network => '192.168.0.0',
        enlaved_if => 'eth1',
           gateway => '192.168.0.1',
         broadcast => '192.168.0.255',
    }
    
    # Lan ntp server provids time services to all lan clients
    class { 'hp_ntp' : role => 'lanserver', local_ntp_srvip => '192.168.0.66',
                       local_ntp_srvnet => '192.168.0.0', local_ntp_srvmask => '255.255.255.0' }
    
	# KVM host virtualisation (based on kvmbr0 - no NAT)
	include hp_kvm_deb
	
	# add KVM 1st guest (based on kvmbr0 - no NAT) -- Wheezy
	hp_kvm_deb::add_guest { 'trise' :
          local_guest_gw => '192.168.0.1', local_guest_ip  => '192.168.0.41', local_mac_address => '52:54:00:00:00:41',
		local_guest_bcst => '192.168.0.255', local_guest_netw => '192.168.0.0',
		 local_hostname  => 'trise', bridge_name => 'kvmbr0', auto_start => 'true',
		 os_name => 'debian', local_guest_netmask => '255.255.255.0', local_guest_domain => 'home.tld',
    }

	# add KVM 2nd guest (based on kvmbr0 - no NAT) -- Wheezy
	hp_kvm_deb::add_guest { 'mc' :
          local_guest_gw => '192.168.0.1', local_guest_ip  => '192.168.0.42', local_mac_address => '52:54:00:00:00:42',
		local_guest_bcst => '192.168.0.255', local_guest_netw => '192.168.0.0',
		 local_hostname  => 'mc', bridge_name => 'kvmbr0', auto_start => 'true',
		 os_name => 'debian', local_guest_netmask => '255.255.255.0', local_guest_domain => 'home.tld',
    }
	
	# add KVM 3rd guest (based on kvmbr0 - no NAT) -- Wheezy 	
	hp_kvm_deb::add_guest { 'deborg' :
          local_guest_gw => '192.168.0.1', local_guest_ip  => '192.168.0.43', local_mac_address => '52:54:00:00:00:43',
		local_guest_bcst => '192.168.0.255', local_guest_netw => '192.168.0.0',
		 local_hostname  => 'deborg', bridge_name => 'kvmbr0', auto_start => 'true',
		 os_name => 'debian', local_guest_netmask => '255.255.255.0', local_guest_domain => 'home.tld',
    }
	
	# add KVM 4th guest (based on kvmbr0 - no NAT)-- Wheezy		
	hp_kvm_deb::add_guest { 'ilx' :
          local_guest_gw => '192.168.0.1', local_guest_ip  => '192.168.0.44', local_mac_address => '52:54:00:00:00:44',
		local_guest_bcst => '192.168.0.255', local_guest_netw => '192.168.0.0',
		 local_hostname  => 'ilx', bridge_name => 'kvmbr0', auto_start => 'true',
		 os_name => 'debian', local_guest_netmask => '255.255.255.0', local_guest_domain => 'home.tld',
    }
	
	# add KVM 5th guest (based on kvmbr0 - no NAT) -- OracleLinux 6		
	hp_kvm_deb::add_guest { 'ora' :
          local_guest_gw => '192.168.0.1', local_guest_ip  => '192.168.0.45', local_mac_address => '52:54:00:00:00:45',
		local_guest_bcst => '192.168.0.255', local_guest_netw => '192.168.0.0',
		 local_hostname  => 'ora', bridge_name => 'kvmbr0', auto_start => 'true',
		 os_name => 'oracle6', local_guest_netmask => '255.255.255.0', local_guest_domain => 'home.tld',
    }
	
	
    ## USER PROFILES ##
	
	# Set up root's home directories and bash customization
    include hp_root_home
    include hp_root_bashrc
    
    # Set up user's home directories and bash customization
    hp_user_bashrc::config { 'bekr' : }
	hp_sudo::config { 'bekr': }
	
	# Enable NFS for user 'bekr' (really just creates the mount point in users' home)
	# This is required for virt-install OracleLinux VM on this Debian KVM host
    class { 'hp_nfs4client_deb::config' : user => 'bekr' }	
    
    
    ## APPLICATIONS ##
    
	# DEBIAN packages without any special configurations
    class { hp_install_debs : debs => [ "tree", "sipcalc", "lshw", "pydf" , "dnsutils", "chkconfig", "virt-top" ] }
    
	# MAIL server (relay external mails via google smtp)
	hp_postfix::install { 'mta' :
			            ensure => 'installed',
			install_cyrus_sasl => 'true',
			          mta_type => 'server',
		 server_root_mail_user => 'bekr',
	external_root_gmail_cc => 'bertil.kronlund',
		   smtp_relayhost_fqdn => 'smtp.gmail.com',
		  no_lan_outbound_mail => 'false',
		    mymailserverdomain => 'home.tld',
	}
	
    ## SECURITY

	# Security (iptables + fail2ban)
	# fail2ban ssh is enabled. disabled apache, modsec, postfix actions
	# latter parameters needs both apache and mod-security installed
    class { hp_iptables_fail2ban::config :
		 puppetserver_hostname => 'hp',
		   fail2ban_trusted_ip => '192.168.0.0/24  81.237.0.0/16',
		       fail2ban_apache => 'false',
		       fail2ban_modsec => 'false',
			  fail2ban_postfix => 'true',
	}

    # Automatic security upgrades with cron script
	include hp_auto_upgrade
	
    ## MAINTENANCE
	#  Note: Before installing new ssh-configuration, first create rsa keys on remost
	#  managing host and "$ ssh-copy-id -i /home/bekr/.ssh/id_hp_rsa bekr@192.168.0.66"
	include hp_ssh_server
    hp_ssh_server::sshuser { 'bekr' : }

	include hp_logwatch
	
	# Disable ipv6 in kernel/grub and use the more text lines in console mode
	class { hp_grub::install : defaultline => 'vga=791', appendline => 'true', ipv6 => 'false' }

}

#################################################
#       VIRTUAL GUESTS IN HP.HOME.TLD           #
#################################################

node 'trise.home.tld' {

    ## BASIC
    include hp_puppetize
    include puppet_utils
	
	# hosts file (hostname, domain name for puppetserver is usually 'puppet.home.tld' and master ip address)
	class { hp_hosts::config : srv_hostname => 'puppet', srv_domain => 'home.tld', srv_host_ip => '192.168.0.66' }

    # ntp service for client
    class { 'hp_ntp' : role => 'lanclient', local_ntp_srvip => '192.168.0.66',
                      local_ntp_srvnet => '192.168.0.0', local_ntp_srvmask => '255.255.255.0' }


    ## USER PROFILES ##
	
	# Set up root's home directories and bash customization
    include hp_root_home
    include hp_root_bashrc
    
    # Set up user's home directories and bash customization
    hp_user_bashrc::config { 'bekr' : }
	hp_sudo::config { 'bekr': }
    
    
    ## APPLICATIONS ##
    
	# DEBIAN packages without any special configurations
    class { hp_install_debs : debs => [ "tree", "sipcalc", "lshw", "pydf" , "dnsutils", "chkconfig", "liblog-log4perl-perl" ] }

    # APACHE2 prefork
    include hp_apache2 
		
	## Define a new Apache2 virtual host (docroot directory writable by group 'root')
    hp_apache2::vhost { 'trise.home.tld' :
            priority => '001',
          devgroupid => 'root',
          execscript => 'none',
		  site_ipaddr => '192.168.0.41',
			    port => '80',
    }


    ## SECURITY

	# Security (iptables + fail2ban)
	# fail2ban ssh is enabled. disabled apache, modsec, postfix actions
	# latter parameters needs both apache and mod-security installed
    class { hp_iptables_fail2ban::config :
		 puppetserver_hostname => 'trise',
		   fail2ban_trusted_ip => '192.168.0.0/24  81.237.0.0/16',
		       fail2ban_apache => 'true',
		       fail2ban_modsec => 'true',
			  fail2ban_postfix => 'false',
	}

    # Automatic security upgrades with cron script
	include hp_auto_upgrade
	
    ## MAINTENANCE
	#  Note: Before installing new ssh-configuration, first create rsa keys on remost
	#  managing host and "$ ssh-copy-id -i /home/bekr/.ssh/id_trise_rsa bekr@192.168.0.41"
	include hp_ssh_server
    hp_ssh_server::sshuser { 'bekr' : }	
	
	include hp_logwatch
	
	# Disable ipv6 in kernel/grub and use the more text lines in console mode
	class { hp_grub::install : defaultline => 'vga=791', appendline => 'true', ipv6 => 'false' }	

}

###############################################################

node 'mc.home.tld' {

    ## BASIC
    include hp_puppetize
    include puppet_utils
	
	# hosts file (hostname, domain name for puppetserver is usually 'puppet.home.tld' and master ip address)
	class { hp_hosts::config : srv_hostname => 'puppet', srv_domain => 'home.tld', srv_host_ip => '192.168.0.66' }

    # ntp service for client
    class { 'hp_ntp' : role => 'lanclient', local_ntp_srvip => '192.168.0.66',
                      local_ntp_srvnet => '192.168.0.0', local_ntp_srvmask => '255.255.255.0' }


    ## USER PROFILES ##
	
	# Set up root's home directories and bash customization
    include hp_root_home
    include hp_root_bashrc
    
    # Set up user's home directories and bash customization
    hp_user_bashrc::config { 'bekr' : }
	hp_sudo::config { 'bekr': }
    
    
    ## APPLICATIONS ##
    
	# DEBIAN packages without any special configurations
    class { hp_install_debs : debs => [ "tree", "sipcalc", "lshw", "pydf" , "dnsutils", "chkconfig", "liblog-log4perl-perl" ] }
    
    # APACHE2 prefork
    include hp_apache2 
		
	## Define a new Apache2 virtual host (docroot directory writable by group 'root')
    hp_apache2::vhost { 'mc.home.tld' :
            priority => '001',
          devgroupid => 'root',
          execscript => 'none',
		 site_ipaddr => '192.168.0.42',
		  	    port => '80',
    }

	
    ## SECURITY	
	
	# Automatic security upgrades with cron script
	include hp_auto_upgrade

	# Security (iptables + fail2ban)
	# fail2ban ssh is enabled. disabled apache, modsec, postfix actions
	# latter parameters needs both apache and mod-security installed
    class { hp_iptables_fail2ban::config :
		 puppetserver_hostname => 'mc',
		   fail2ban_trusted_ip => '192.168.0.0/24  81.237.0.0/16',
		       fail2ban_apache => 'true',
		       fail2ban_modsec => 'true',
			  fail2ban_postfix => 'false',
	}	
	
    ## MAINTENANCE
	#  Note: Before installing new ssh-configuration, first create rsa keys on remost
	#  managing host and "$ ssh-copy-id -i /home/bekr/.ssh/id_mc_rsa bekr@192.168.0.42"
	include hp_ssh_server
    hp_ssh_server::sshuser { 'bekr' : }		
	
	include hp_logwatch
	
	# Disable ipv6 in kernel/grub and use the more text lines in console mode
	class { hp_grub::install : defaultline => 'vga=791', appendline => 'true', ipv6 => 'false' }	
	
}

###############################################################

node 'deborg.home.tld' {

    ## BASIC
    include hp_puppetize
    include puppet_utils
	
	# hosts file (hostname, domain name for puppetserver is usually 'puppet.home.tld' and master ip address)
	class { hp_hosts::config : srv_hostname => 'puppet', srv_domain => 'home.tld', srv_host_ip => '192.168.0.66' }

    # ntp service for client
    class { 'hp_ntp' : role => 'lanclient', local_ntp_srvip => '192.168.0.66',
                      local_ntp_srvnet => '192.168.0.0', local_ntp_srvmask => '255.255.255.0' }


    ## USER PROFILES ##
	
	# Set up root's home directories and bash customization
    include hp_root_home
    include hp_root_bashrc
    
    # Set up user's home directories and bash customization
    hp_user_bashrc::config { 'bekr' : }
	hp_sudo::config { 'bekr': }
    
    
    ## APPLICATIONS ##
    
	# DEBIAN packages without any special configurations
    class { hp_install_debs : debs => [ "tree", "sipcalc", "lshw", "pydf" , "dnsutils", "chkconfig", "liblog-log4perl-perl" ] }

    # APACHE2 prefork
    include hp_apache2 
		
	## Define a new Apache2 virtual host (docroot directory writable by group 'root')
    hp_apache2::vhost { 'deborg.home.tld' :
            priority => '001',
          devgroupid => 'root',
          execscript => 'none',
		 site_ipaddr => '192.168.0.43', 
		        port => '80',
    }


    ## SECURITY

	# Security (iptables + fail2ban)
	# fail2ban ssh is enabled. disabled apache, modsec, postfix actions
	# latter parameters needs both apache and mod-security installed
    class { hp_iptables_fail2ban::config :
		 puppetserver_hostname => 'deborg',
		   fail2ban_trusted_ip => '192.168.0.0/24  81.237.0.0/16',
		       fail2ban_apache => 'true',
		       fail2ban_modsec => 'true',
			  fail2ban_postfix => 'false',
	}

    # Automatic security upgrades with cron script
	include hp_auto_upgrade
	
    ## MAINTENANCE
	#  Note: Before installing new ssh-configuration, first create rsa keys on remost
	#  managing host and "$ ssh-copy-id -i /home/bekr/.ssh/id_deborg_rsa bekr@192.168.0.43"
	include hp_ssh_server
    hp_ssh_server::sshuser { 'bekr' : }			
	
	include hp_logwatch
	
	# Disable ipv6 in kernel/grub and use the more text lines in console mode
	class { hp_grub::install : defaultline => 'vga=791', appendline => 'true', ipv6 => 'false' }	
	
}

###############################################################

node 'ilx.home.tld' {

    ## BASIC
    include hp_puppetize
    include puppet_utils
	
	# hosts file (hostname, domain name for puppetserver is usually 'puppet.home.tld' and master ip address)
	class { hp_hosts::config : srv_hostname => 'puppet', srv_domain => 'home.tld', srv_host_ip => '192.168.0.66' }

    # ntp service for client
    class { 'hp_ntp' : role => 'lanclient', local_ntp_srvip => '192.168.0.66',
                      local_ntp_srvnet => '192.168.0.0', local_ntp_srvmask => '255.255.255.0' }


    ## USER PROFILES ##
	
	# Set up root's home directories and bash customization
    include hp_root_home
    include hp_root_bashrc
    
    # Set up user's home directories and bash customization
    hp_user_bashrc::config { 'bekr' : }
	hp_sudo::config { 'bekr': }


    ## APPLICATIONS ##
    
	# DEBIAN packages without any special configurations
    class { hp_install_debs : debs => [ "tree", "sipcalc", "lshw", "pydf" , "dnsutils", "chkconfig", "liblog-log4perl-perl" ] }

    # APACHE2 prefork
    include hp_apache2 
		
	## Define a new Apache2 virtual host (docroot directory writable by group 'root')
    hp_apache2::vhost { 'ilx.home.tld' :
            priority => '001',
          devgroupid => 'root',
          execscript => 'none',
		 site_ipaddr => '192.168.0.44', 
		        port => '80',
    }

    ## SECURITY

    # Automatic security upgrades with cron script
	include hp_auto_upgrade
	
	# Security (iptables + fail2ban)
	# fail2ban ssh is enabled. disabled apache, modsec, postfix actions
	# latter parameters needs both apache and mod-security installed
    class { hp_iptables_fail2ban::config :
		 puppetserver_hostname => 'ilx',
		   fail2ban_trusted_ip => '192.168.0.0/24  81.237.0.0/16',
		       fail2ban_apache => 'true',
		       fail2ban_modsec => 'true',
			  fail2ban_postfix => 'false',
	}
	
    ## MAINTENANCE
	#  Note: Before installing new ssh-configuration, first create rsa keys on remost
	#  managing host and "$ ssh-copy-id -i /home/bekr/.ssh/id_ilx_rsa bekr@192.168.0.43"
	include hp_ssh_server
    hp_ssh_server::sshuser { 'bekr' : }			
	
	include hp_logwatch

	# Disable ipv6 in kernel/grub and use the more text lines in console mode
	class { hp_grub::install : defaultline => 'vga=791', appendline => 'true', ipv6 => 'false' }	

}

###############################################################

# This is a OracleLinux-6 'minimal-install' guest (aka rhel 6 minimal)
# Before this add EPEL-repo and add below required rpms manually.
# Note this installs puppet agent 2.7!
node 'ora.home.tld' {

   ## BASIC
   # (required for command 'virsh shutdown ora' to work) 
	include hp_acpid_rpm

    ## APPLICATIONS
	
    #Install REDHAT packages without any special configurations
    class { hp_install_rpms : rpms => [ "nano", "bind-utils", "wget", "perl-Log-Log4perl", "openssh-clients" ] }
}

#
## eof
#
