#
# Define new Apache2 module and load it
#
# Sample usage:
#
#     hp_apache2_rpm::module { 'mod-security' : } 
#
define hp_apache2_rpm::module {
 
    include hp_apache2_rpm
	include hp_iptables_fail2ban
    
	case $name {
	
		'mod-security': {
	
			# Install required OracleLinux-6 packages
			package { [ "libxml2", "libxml2-devel", "httpd-devel", "pcre-devel", "libcurl-devel" ] :
				ensure => installed,
				allow_virtual => true,
				require => Package["httpd"],
			}
					
			# Install mod-security
			package { "mod_security" :
				ensure => installed,
				allow_virtual => true,				
				require => Package["libxml2", "libxml2-devel", "httpd-devel", "pcre-devel", "libcurl-devel"],
			}
			
			## Copy our configuration file with rules for mod-security
			#file { "/etc/modsecurity/modsecurity.conf":
			#	source => "puppet:///modules/hp_apache2_rpm/modsecurity.conf",    
			#	owner => 'root',
			#	group => 'root',
			#	mode => '0644',
			#	require => Package["modsecurity-crs"],
			#	notify => Service["httpd"],
			#}   	
			#
			## Create private temp directory, writable for apache (www-data)
			#file { "/var/tmp/modsecurity" :
			#	ensure => 'directory',
			#	owner => 'httpd',
			#	group => 'root',
			#	mode => '0770',  
			#	require => File["/etc/modsecurity/modsecurity.conf"],
			#}		
			#
			## Only install regexp modsec-filter if fail2ban is installed
			#file { "/etc/fail2ban/filter.d/modsec.conf" :
			#	source => "puppet:///modules/hp_apache2_rpm/modsec.conf",    
			#	require => Package["fail2ban"],
			#}						
			#
			## Only enable if not already enabling symlink exist,
			## if so restart apache to include new module
			#exec { "Exec_enable_$name":
			#	command => "/usr/sbin/a2enmod $name >> /dev/null",		
			#	path   => "/usr/bin:/usr/sbin:/bin",
			#	unless => "test -e /etc/apache2/mods-enabled/$name.load",
			#	require => File["/etc/modsecurity/modsecurity.conf"],
			#	notify => Service["httpd"],
			#}			
			
		}
		
		'headers': {
		
			# Only enable if not already enabling symlink exist,
			# if so restart apache to include new module
			#exec { "Exec_enable_$name":
			#    command => "/usr/sbin/a2enmod $name >> /dev/null",		
			#    path   => "/usr/bin:/usr/sbin:/bin",
			#    unless => "test -e /etc/apache2/mods-enabled/$name.load",
			#    require => Package["httpd"],
			#    notify => Service["httpd"],
			#}
		}
			
		'default': {	
			fail("FAIL: Not yet defined process for Apache module ($name)")
		}
		
	}

}
