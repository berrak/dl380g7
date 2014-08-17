##
##  Sample use:
##      hp_sudo::config { 'bekr': }
##
define hp_sudo::config {

    include hp_sudo

    exec { "Add_${name}_To_Administrator_Group" :
            command => "usermod -a -G sudo $name",
               path => '/usr/bin:/usr/sbin:/bin',
             unless => "groups $name | grep sudo",
            require => Package["sudo"],
    }    
    
}