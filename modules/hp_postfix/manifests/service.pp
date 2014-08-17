#
# Module to manage one central postfix server mta.
# In/outgoing mail via ISP smtp host. 
#
class hp_postfix::service {

    service { "postfix" :
		    ensure => running,
		 hasstatus => true,
		hasrestart => true,
		    enable => true,
		   require => Package["postfix"],
	}

}