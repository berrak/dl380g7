##
## This class starts the NFS service
##
class hp_nfs4client_deb::service {

	service { "nfs-common":
		
		    ensure => running,
		 hasstatus => true,
		hasrestart => true,
		    enable => true,
		   require => Class["hp_nfs4client_deb::install"],

	}

}
