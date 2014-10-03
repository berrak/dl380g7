##
## Add non-privileged sshuser to login to the ssh-server
##
define hp_ssh_server::config::sshuser ( $loginuser='' ) {

    include hp_ssh_server
    
    if $loginuser == '' {
        fail("FAIL: No non-priveleged user give!. Aborting...")
    }

    exec { "add_${loginuser}_to_sshusers_group" :
            command => "usermod -a -G sshusers $loginuser",
               path => '/usr/bin:/usr/sbin:/bin',
             unless => "cat /etc/group | grep sshusers | grep $loginuser",
            require => Class["hp_ssh_server"],
    }

}