##
## Add non-privileged sshuser to login to the ssh-server
##
## Sample usage:
##		hp_ssh_server::sshuser { 'bekr' : }
##
define hp_ssh_server::sshuser {

    include hp_ssh_server
    
    if $name == '' {
        fail("FAIL: No non-priveleged user given!. Aborting...")
    }

    exec { "add_${name}_to_sshusers_group" :
            command => "usermod -a -G sshusers $name",
               path => '/usr/bin:/usr/sbin:/bin',
             unless => "cat /etc/group | grep sshusers | grep $name",
            require => Class["hp_ssh_server"],
    }

}