##
## Class to change state of selinux
##
## Sample usage:
##		hp_selinux::state { 'enforcing' : }
##		hp_selinux::state { 'permissive' : }
##		hp_selinux::state { 'disable' : }
##
define hp_selinux::state {

    include hp_selinux
    
    
    if $name == '' {
        fail("FAIL: SELINUX wanted state not given! Aborting...")
    }
    
	$ostype = $::lsbdistid
	
	if $ostype == 'OracleServer' {
	
		case $name {
		  'enforcing': {
		  
		  fail("FAIL: $name. Halting puppet run (test)")
		  
		  
		  }
		  'permissive': {
		  
		  
		  fail("FAIL: $name. Halting puppet run (test)")		  
		  
		  }
		  'disable': {
		  
		  fail("FAIL: $name. Halting puppet run (test)")		  
		  
		  
		  }
		  default: { 
			fail("FAIL: SELINUX unknown state $name. Aborting...")
		  }
		  
		}
        
	} else {
		fail("FAIL: SELINUX on unsupported $ostype distribution. Aborting...")
	}
    
}
    
    