##
## Hardening a host.
##
class hp_hardening::shutdown {

    # only allow logged-in accounts and only root to 'Ctrl-Alt-Del' to reboot.
    
    include puppet_utils
    
    puppet_utils::append_if_no_such_line { "ctrlaltdel_allow" :
            
        file => "/etc/shutdown.allow",
        line => "# This line prevents false positives from tiger." 
    
    }
    
}