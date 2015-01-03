#
# Git server
#
# (required on all machines acting 'puppetmaster' and
# on any host that acts as git development repository)
#
class hp_git_server {

    include hp_git_server::install

}
