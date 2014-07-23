#########################################
## (BASENODE) Included in every node
#########################################
node basenode {

	# puppet helper routines
	include puppet_utils

    # Set up root's home directories and bash customization
    include hp_root_home
    include hp_root_bashrc

}
###############################
## eof
###############################