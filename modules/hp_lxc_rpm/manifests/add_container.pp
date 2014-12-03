#
# This define adds a new NAT system container (latest version of EL6)
#
# Usage: hp_lxc_rpm::add_container { '198.168.0.40' :
#            					run_cont => 'true',
#            					cont_host_name => 'deborg',
#            					cont_private_mac_addr => '52:54:00:00:00:40',
#}
#        
define hp_lxm_rpm::add_guest ( $run_cont, $cont_host_name, $cont_private_mac_addr ) {

    include hp_lxm_rpm
	
	$cont_public_ip = $name 
	
    if ! ( $::lsbdistid == 'OracleServer' ) {
        fail("FAIL: Aborting. This module (hp_lxc_rpm) is only for OracleLinux based distributions!")
    }
	
	if ( $cont_public_ip == '' ) {
		fail("FAIL: Missing given public IP address for container!")
	}

	if ( $cont_private_mac_addr == '' ) {
		fail("FAIL: Missing given container MAC address!")
	}
	
	if ( $cont_host_name == '' ) {
		fail("FAIL: Missing given virtual host name!")
	}
	
	# create the new container (OracleLinux EL6.latest)
	exec { "Create_new_container_$cont_host_name" :
		   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
		command => "lxc-create -n $cont_host_name -t oracle -- --release=6.latest",
		 unless => "lxc-ls | grep $cont_host_name",
		require => Package["lxc"],
		 notify => File["/container/$cont_host_name/config"],
	}

	# create the container configuration -
	# TODO: how about configuration changes -- stop-start exec?
	file { "/container/$cont_host_name/config":
		content =>  template( "hp_lxm_rpm/$cont_host_name.config.erb" ),
		  owner => 'root',
		  group => 'root',
	}

	# run the container
	if ( $run_cont == 'true' ) {
		
        # start container if stopped
        exec { "RUN_container_$cont_host_name" :
                   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
                command => "lxc-start -n $cont_host_name -d", 
            refreshonly => 'true',
              subscribe => File["/container/$cont_host_name/config"],
                require => File["/container/$cont_host_name/config"],
                 onlyif => "lxc-info -n $cont_host_name | grep STOPPED",
        }
		
	} else {
	    
		# stop the container if running
		exec { "STOP_container_$cont_host_name" :
			   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
			command => "lxc-stop -n $cont_host_name", 
		refreshonly => 'true',
		  subscribe => File["/container/$cont_host_name/config"],
			require => File["/container/$cont_host_name/config"],
			 onlyif => "lxc-info -n $cont_host_name | grep RUNNING",
		}
	
	}
		
}