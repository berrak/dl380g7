##
## Puppet manage openssh server
##
class hp_ssh_server::install {
    
    package { "openssh-server":
               ensure => installed,
        allow_virtual => true,        
        }
 
}