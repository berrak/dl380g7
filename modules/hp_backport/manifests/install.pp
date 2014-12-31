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
        
			exec { "/usr/bin/apt-get install git/wheezy-backports" :
				refreshonly => true,
			}	   			
        }

        default: {
		
            fail("FAIL: Package name ($name) is not recognized! Update manifest hp_backport::install.pp")
        }
    }
}
