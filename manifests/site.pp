#
## site.pp (Tested dists: Debian 7.X, OracleLinux 6.X)
#
$extlookup_precedence = ["fstab_sda1_uuid"]
$extlookup_datadir = "/etc/puppet/files"

## Development server, Oracle Linux 6.5
node 'ol65.home.tld' {

    ## BASIC
    
    # Enable dnsmasq for DNS
    #class { hp_dnsmasq::config :
    #            ispdns1 => '208.67.222.222',
    #            ispdns2 => '208.67.220.220',
    #            real_hostname => 'ol65',
    #}
    
    # above DNS must resolv before 'hp_pupetize'. Note that 'puppet-server'
    # host will be named 'puppet'. Oracle use latest puppet-server 3.7
    #include hp_puppetize
    #include puppet_utils
    
    # primary host networking configuration (generate uuid with 'uuidgen')
    #hp_network_rpm::config { 'eth0'  :
    #            ip => '192.168.0.66',
    #            prefix => '24',
    #            uuid => '8f83faf4-4ac3-4211-8616-1a87c6244039',
    #            gateway => '192.168.0.1',
    #            broadcast => '192.168.0.255',
    #            ispdns1 => '195.67.199.18',
    #            ispdns2 => '195.67.199.19',
    #}
    
    # virtual network aliases PUBLIC interfaces for KVM guests
    #hp_network_rpm::alias { 'eth0:0' : public_guest_ip => '192.168.0.122', onboot => 'yes' }  
    
    # set up KVM and two networks (NAT at subnet 122 and one routed subnet 40) for VM guests
    #class { hp_kvm_rpm::config :
    #            natnet_default_active => 'true',
    #            routednet_name => 'routed40',
    #            routednet_active => 'false',
    #            routed_br_name => 'virbr1',
    #            routed_host_if => 'eth1',
    #            routed_uuid => '02bfac05-336c-4a2a-b533-1f4a472bcdfc',
    #}
    
    # -- first guest (subnet 192.168.122.0/24) -  network
    # -- Note: hostname must use only 'a-z' or '.' (no - or _ in hostname)
    #hp_kvm_rpm::add_guest { 'debinixorg' :
    #            local_guest_ip  => '192.168.122.122',
    #            local_guest_gw  => '192.168.122.1',                  
    #            local_guest_bcst => '192.168.122.255',
    #            local_guest_netw => '192.168.122.0',
    #            local_hostname  => 'deborg',
    #                bridge_name => 'virbr0',
    #            routed_network  => 'routed40',
    #            guest_uuid => '4a6e421b-d4aa-46d5-b484-c81b9e812f60',
    #}
    

    
    # temporary skip fstab final entry
    #class { hp_fstab::config : fstabhost => 'ol65' }
    
    # This is the ntp server for localnet
    #class { hp_ntp : role => 'lanserver', peerntpip => '192.168.0.66' }
    #include hp_smartmontools
    
    ## USER PROFILES (note user must first exist)
    
    #include hp_root_home
    #include hp_root_bashrc
    # add local users
    #hp_user_bashrc::config { 'bekr' : }

    
    ## APPLICATIONS
	# Install REDHAT packages without any special configurations
    #class { hp_install_rpms : rpms => [ "tree", "ethtool", "parted", "lsof", "curl" ] }
    
    
    ## SECURITY
    #hp_selinux::state { 'enforcing' : }
    #hp_sudo::config { 'bekr': }
    #include hp_logwatch
    #include hp_iptables_rpm
    
    # Enable mac filtering but no custom rules yet - libvirt adds own chains
    #include hp_ebtables_rpm    
    
    # disable unnecessary services
    #hp_service::disable { 'atd' : }
    #hp_service::disable { 'autofs' : }
    #hp_service::disable { 'kdump' : }
    #hp_service::disable { 'rhnsd' : }
    #hp_service::disable { 'mdmonitor' : }  
    #hp_service::disable { 'portreserve' : }
    
    # remove these, for a server unnecessary REDHAT packages
    #class { hp_remove_rpms : rpms => [ "cups" ] }
    
    
    ## MAINTENANCE
#	include hp_ssh_server
#    hp_ssh_server::sshuser { 'bekr' : }
    include hp_auto_upgrade
    #include hp_logrotate
    #include hp_rsyslog

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
#
## eof
#