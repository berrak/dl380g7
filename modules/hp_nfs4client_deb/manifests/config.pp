##
## Manage NFSv4 client
##
## Usage:
##     class { hp_nfs4client_deb: user => 'bekr' }
##
class hp_nfs4client_deb::config ( $user ='' ) {

    include hp_nfs4client_deb::params
	include hp_nfs4client_deb::install
	include hp_nfs4client_deb::service

    if $user == '' {
    
        fail("FAIL: Missing the user ($user) parameter")
    }

    # create local nfs mount directory for $user
    
	file { "/home/$user/nfs":
		ensure => "directory",
		 owner => $user,
		 group => $user,
          mode => '0755',
	}
	
	# nfs-common configuration - note: pure NFSv4 doesn't need legacy NFSv3 daemons
	
    file { '/etc/default/nfs-common':
        source =>  "puppet:///modules/hp_nfs4client_deb/nfs-common",  
         owner => 'root',
         group => 'root',
		notify => Class["hp_nfs4client_deb::service"],
    }

    # the UID/GID mapping daemon configuration

	$mydomain = $::domain
	
    file { '/etc/idmapd.conf':
        content =>  template( 'hp_nfs4client_deb/idmapd.conf.erb' ),  
          owner => 'root',
          group => 'root',
		 notify => Class["hp_nfs4client_deb::service"],
    }	

}
