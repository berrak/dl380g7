#
## site.pp
#
$extlookup_precedence = ["fstab_sda1_uuid"]
$extlookup_datadir = "/etc/puppet/files"

node 'node-hphome.home.tld' {

	# puppet helper routines
    include puppet_utils
	# manage puppet itself
    include hp_puppetize
	
	# Disable ipv6 in kernel/grub and use the more text lines in console mode	
    class { hp_grub::install : defaultline => 'vga=791', appendline => 'true', ipv6 => 'false' }

    # Set up root's home directories and bash customization
    include hp_root_home
    include hp_root_bashrc
	
	# hosts and fstab files
	class { hp_hosts::config : puppetserver_hostname => 'hphome' }
	class { hp_fstab::config : fstabhost => 'hphome' }
	
	# security (iptables + fail2ban)
	# fail2ban ssh is enabled. disabled apache, modsec, postfix actions
	# latter parameters needs both apache and mod-security installed
    class { hp_iptables_fail2ban::config :
		 puppetserver_hostname => 'hphome',
		   fail2ban_trusted_ip => '192.168.0.0/24',
		       fail2ban_apache => 'false',
		       fail2ban_modsec => 'false',
			  fail2ban_postfix => 'false',
	}
    # automatic security upgrades with cron script
	include hp_auto_upgrade

}
#
## eof
#