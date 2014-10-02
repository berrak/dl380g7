##
##  Sample use:
##      hp_sudo::config { 'bekr': }
##
define hp_sudo::config {

    include hp_sudo
    
    $ostype = $::lsbdistid
	
	exec { "add_group_sudo" :
            command => "groupadd -r sudo",
               path => '/usr/bin:/usr/sbin:/bin',
             unless => "cat /etc/group | grep sudo",	
	    require => Package["sudo"],
	}
	
    exec { "add_${name}_to_sudo_group" :
            command => "usermod -a -G sudo $name",
               path => '/usr/bin:/usr/sbin:/bin',
             unless => "cat /etc/group | grep sudo | grep $name",
            require => Exec["add_group_sudo"],
    }
    
    # use '/etc/sudoers.d' directory to add group sudo for OracleLinux
    if $ostype == 'OracleServer' {
    
        file { "/etc/sudoers.d/sudogrp":
            content =>  template( "hp_sudo/sudogrp.erb" ),
              owner => 'root',
              group => 'root',
               mode => '0440',
            require => Package["sudo"],
        }		
    
    }
    
}