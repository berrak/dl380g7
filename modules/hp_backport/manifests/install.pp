#
# Sample usage:
#
#            hp_backport::install { 'git' : }
#
define hp_backport::install {
  
	if ( $::operatingsystem != 'Debian' ) {
	
		fail("FAIL: This module is only for Debian, not for $::operatingsystem. Aborting...")
	}

    case $name {
    
        git : {
        
			exec { "/usr/bin/apt-get install $name/wheezy-backports" :
				   path => '/bin:/usr/bin:/sbin:/usr/sbin',
				command => "apt-get install $name/wheezy-backports",
				 unless => "dpkg -l $name", 
			}	   			
        }

        default: {
		
            fail("FAIL: Package name ($name) is not recognized! Update manifest hp_backport::install.pp")
        }
    }
}
