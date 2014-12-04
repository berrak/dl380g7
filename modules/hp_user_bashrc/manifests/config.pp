##
## This define customize desktop users's .bashrc
##
## Sample usage:
##		hp_user_bashrc::config { 'bekr' : }
##
define hp_user_bashrc::config {
    
	include puppet_utils
	
	# user directory must exist (but may have been created outside puppet)
	file { "/home/${name}":
		ensure => "directory",
		 owner => "${name}",
		 group => "${name}",
	}	
	
    # Handle some differences between Debian and OracleLinux(OracleLinux)
	
    $ostype = $::operatingsystem

	# replace OL6 default .bashrc (to only source global bashrc)
    if $ostype == 'OracleLinux'  {

	    file { "/home/${name}/.bashrc":
			source => "puppet:///modules/hp_user_bashrc/bashrc_rpm",
			 owner => "${name}",
			 group => "${name}",
			  mode => '0644',
		   require => File["/home/${name}"],
	   	}

    } 
	

    # array of real users...(not root, or system accounts)
		
    if ( $name in ["bekr" ] ) {
		
		# create a couple of standard sub directories for the user
		
        file { "/home/${name}/bin":
		    ensure => "directory",
		     owner => "${name}",
		     group => "${name}",
		   require => File["/home/${name}"],
	    }		
		
        file { "/home/${name}/tmp":
		    ensure => "directory",
		     owner => "${name}",
		     group => "${name}",
		   require => File["/home/${name}"],
	    }		
	
        file { "/home/${name}/bashwork":
		    ensure => "directory",
		     owner => "${name}",
		     group => "${name}",
		   require => File["/home/${name}"],
	    }			

        file { "/home/${name}/perlwork":
		    ensure => "directory",
		     owner => "${name}",
		     group => "${name}",
		   require => File["/home/${name}"],			 
	    }			
	
        # ensure that a local .bashrc sub directory for our snippets exist 
    
        file { "/home/${name}/bashrc.d":
		    ensure => "directory",
		     owner => "${name}",
		     group => "${name}",
		   require => File["/home/${name}"],
	    }		
		
		if $ostype == 'Debian' {
		
			# Now append one line to original .bashrc to source user customizations.
			puppet_utils::append_if_no_such_line { "enable_${name}_customization" :
					
				file => "/home/${name}/.bashrc",
				line => "[ -f ~/bashrc.d/${name} ] && source ~/bashrc.d/${name}" 
			
			}
		} elsif $ostype == 'OracleLinux' {
		
           	file { "/home/${name}/.bash_profile":
				content =>  template( "hp_user_bashrc/bash_profile_rpm.erb" ),
				  owner => "${name}",
				  group => "${name}",
				require => File["/home/${name}"],
            }		
		
		} else {
		    fail("FAIL: Unknown $ostype distribution. Aborting...")
		}
	
	    # add the actual 'user' customization file to the .bashrc.d snippet directory
		
	    file { "/home/${name}/bashrc.d/${name}":
			source => "puppet:///modules/hp_user_bashrc/${name}",
			 owner => "${name}",
			 group => "${name}",
			  mode => '0644',
		   require => File["/home/${name}/bashrc.d"],
	   	}
		
		# perl rc file, automatically sourced at login
		
	    file { "/home/${name}/bashrc.d/perl.rc":
			source => "puppet:///modules/hp_user_bashrc/perl.rc",
			 owner => "${name}",
			 group => "${name}",
			  mode => '0644',
		   require => File["/home/${name}/bashrc.d/${name}"],
	   	}
		
		# add more rc-specific files here

	
	} else {
		
	    fail("FAIL: Unknown user ($name) for puppet on this host!")
		
	}
	

}
