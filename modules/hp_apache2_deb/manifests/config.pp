#
# Manage apache2
#
class hp_apache2_deb::config {

    # Global security settings
    
    file { '/etc/apache2/conf.d/security':
         source => "puppet:///modules/hp_apache2_deb/security",    
          owner => 'root',
          group => 'root',
        require => Class["hp_apache2_deb::install"],
        notify => Service["apache2"],
    }

    file { '/etc/apache2/ports.conf':
        content =>  template('hp_apache2_deb/ports.conf.erb'),
          owner => 'root',
          group => 'root',       
        require => Class["hp_apache2_deb::install"],
        notify => Service["apache2"],
    }
    
	## Disable apache Debian maintainer default site link/file configuration
	
    file { '/etc/apache2/sites-enabled/000-default':
        ensure => absent,
        target => '/etc/apache2/sites-available/default',
       require => Class["hp_apache2_deb::install"],
	    notify => Service["apache2"],
    }
	
    file { '/etc/apache2/sites-available/default':
        ensure => absent,
       require => Class["hp_apache2_deb::install"],
	    notify => Service["apache2"],
    }	
	
	
    ## Configure the new default vhost (catch all for an unmatched site)
    
	$default_fqdn = $::fqdn
	$site_domain = $::domain
	
    file { '/etc/apache2/sites-available/zdefault':
        content =>  template('hp_apache2_deb/default.erb'),
          owner => 'root',
          group => 'root',       
        require => Class["hp_apache2_deb::install"],
    }

    ## Enable the default vhost site, but put lowest priority
    
    file { '/etc/apache2/sites-enabled/999-zdefault':
        ensure => 'link',
        target => '/etc/apache2/sites-available/zdefault',
       require => Class["hp_apache2_deb::install"],
	    notify => Service["apache2"],
    }
    
	## Ensure that /var/www really exists!
	
	file { "/var/www":
		ensure => "directory",
		owner => 'root',
		group => 'root',
	}	
	
    
	# Create the directory structure for the 'zdefault' site
    
	file { "/var/www/default":
		 ensure => "directory",
		  owner => 'root',
		  group => 'root',
		require => File["/var/www"],		
	}
    
	# Doc root
	
	file { "/var/www/default/public":
		 ensure => "directory",
		 owner => 'root',
		 group => 'root',
		require => File["/var/www/default"],
	}
	
    # Default site index file and favicon (used when site does maintenence)
    
    file { '/var/www/default/public/index.html':
         source => "puppet:///modules/hp_apache2_deb/default.index.html",    
          owner => 'root',
          group => 'root',
        require => File["/var/www/default"],
    }

    file { '/var/www/default/public/favicon.ico':
         source => "puppet:///modules/hp_apache2_deb/tux-favicon.ico",    
          owner => 'root',
          group => 'root',
        require => File["/var/www/default"],
    }  

    # Images in /default/static

	file { "/var/www/default/public/images":
		 ensure => "directory",
		 owner => 'root',
		 group => 'root',
	}
	
    file { '/var/www/default/public/images/toolbox.jpg':
         source => "puppet:///modules/hp_apache2_deb/tux-toolbox.jpg",    
          owner => 'root',
          group => 'root',
        require => File["/var/www/default/public/images"],
    }
    
    # Possible style sheets in /styles
	
	file { "/var/www/default/public/styles":
		 ensure => "directory",
		 owner => 'root',
		 group => 'root',
	}	
	
	
    
}
