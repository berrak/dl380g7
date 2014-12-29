#
# Define new Apache2 module and load it
#
# Sample usage:
#
#     hp_apache2_deb::module { 'mod-security' : } 
#
define hp_apache2_deb::module {
 
    include hp_apache2_deb
	include hp_iptables_fail2ban
    
	case $name {
	
		'mod-security': {
	
			# Install required Debian packages
			package { [ "libxml2", "libxml2-dev","libxml2-utils"] :
				ensure => installed,
				require => Package["apache2-mpm-prefork"],
			}
			
			package { [ "libaprutil1", "libaprutil1-dev"] :
				ensure => installed,
				require => Package["apache2-mpm-prefork"],
			}
		
			# Install mod-security and rule set
			package { [ "libapache-mod-security", "modsecurity-crs"] :
				ensure => installed,
				require => Package["apache2-mpm-prefork"],
			}
			
			# Copy our configuration file with rules for mod-security
			file { "/etc/modsecurity/modsecurity.conf":
				source => "puppet:///modules/hp_apache2_deb/modsecurity.conf",    
				owner => 'root',
				group => 'root',
				mode => '0644',
				require => Package["modsecurity-crs"],
				notify => Service["apache2"],
			}   	
			
			# Create private temp directory, writable for apache (www-data)
			file { "/var/tmp/modsecurity" :
				ensure => 'directory',
				owner => 'www-data',
				group => 'root',
				mode => '0770',  
				require => File["/etc/modsecurity/modsecurity.conf"],
			}		
			
			# Only install regexp modsec-filter if fail2ban is installed
			file { "/etc/fail2ban/filter.d/modsec.conf" :
				source => "puppet:///modules/hp_apache2_deb/modsec.conf",    
				require => Package["fail2ban"],
			}						
			
			# Only enable if not already enabling symlink exist,
			# if so restart apache to include new module
			exec { "Exec_enable_$name":
				command => "/usr/sbin/a2enmod $name >> /dev/null",		
				path   => "/usr/bin:/usr/sbin:/bin",
				unless => "test -e /etc/apache2/mods-enabled/$name.load",
				require => File["/etc/modsecurity/modsecurity.conf"],
				notify => Service["apache2"],
			}			
			
		}
		
		'headers': {
		
			# Only enable if not already enabling symlink exist,
			# if so restart apache to include new module
			exec { "Exec_enable_$name":
			    command => "/usr/sbin/a2enmod $name >> /dev/null",		
			    path   => "/usr/bin:/usr/sbin:/bin",
			    unless => "test -e /etc/apache2/mods-enabled/$name.load",
			    require => Package["apache2-mpm-prefork"],
			    notify => Service["apache2"],
			}
		}
			
		'default': {	
			fail("FAIL: Not yet defined process for Apache module ($name)")
		}
		
	}

}
