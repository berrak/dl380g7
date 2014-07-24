#
## site.pp
#
node 'node-hphome.home.tld' {

    # puppet helper routines
    include puppet_utils
	# manage puppet
    include hp_puppetize

    # Set up root's home directories and bash customization
    include hp_root_home
    include hp_root_bashrc

}
#
## eof
#