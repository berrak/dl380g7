#
## site.pp
#
$extlookup_precedence = ["fstab_sda1_uuid"]
$extlookup_datadir = "/etc/puppet/files"

node 'node-hphome.home.tld' {

	## BASIC
	
	# Puppet helper routines
    include puppet_utils
	# Manage puppet itself
    include hp_puppetize
	
	# Configure APT
    include hp_aptconf
		
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
	                        "pydf" , "dnsutils" , "ethtool", "parted", "lsof" ] }
	
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
	

	## MAINTENANCE
	
	# SSH server - Todo: change conf from pwd to RSA only
	include hp_ssh_server
	
	include hp_logwatch
	
	include hp_rsyslog
	include hp_logrotate
	
	include hp_screen
	

}
#
## eof
#