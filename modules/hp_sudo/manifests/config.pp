##
##  Sample use:
##      hp_sudo::config { 'bekr': }
##
define hp_sudo::config {

    include hp_sudo
    
    $ostype = $::lsbdistid
    
    exec { "Add_${name}_To_Administrator_Group" :
            command => "usermod -a -G sudo $name",
               path => '/usr/bin:/usr/sbin:/bin',
             unless => "groups $name | grep sudo",
            require => Package["sudo"],
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