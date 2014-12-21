##
## Manage NFSv4 client
##
class hp_nfs4client_deb {

    include hp_nfs4client_deb::install, hp_nfs4client_deb::config, hp_nfs4client_deb::service, hp_nfs4client_deb::params

}
