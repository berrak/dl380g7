##
## Puppet manage openssh server
##
class hp_ssh_server {

    include hp_ssh_server::install, hp_ssh_server::config, hp_ssh_server::service

}