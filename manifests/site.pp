#
## site.pp (Tested dists: Debian 7.X, OracleLinux 6.X)
#
$extlookup_precedence = ["fstab_sda1_uuid"]
$extlookup_datadir = "/etc/puppet/files"

## Development server, Oracle Linux 6.5
node 'ol65.home.tld' {

    ## BASIC
    include hp_puppetize
    include puppet_utils
    
    # This is the ntp server for localnet
    class { 'hp_ntp' : role => 'lanserver', peerntpip => '192.168.0.66' }
    class { hp_hosts::config : puppetserver_hostname => 'ol65' }
    class { hp_fstab::config : fstabhost => 'ol65' }
    
    ## USER PROFILES
    
    include hp_root_home
    include hp_root_bashrc
    ## add local users
    hp_user_bashrc::config { 'bekr' : }

    
    
    ## APPLICATIONS


    ## SECURITY
    hp_sudo::config { 'bekr': }
    
    
    ## MAINTENANCE
	include hp_ssh_server
    hp_ssh_server::sshuser { 'bekr' : }

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
	

	## MAINTENANCE
	
	# SSH server
	include hp_ssh_server
	
	include hp_logwatch
	
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