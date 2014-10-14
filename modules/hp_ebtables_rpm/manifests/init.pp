##
## This class manage ebtables
##
class hp_ebtables_rpm {

    include hp_ebtables_rpm::install,
			hp_ebtables_rpm::config,
            hp_ebtables_rpm::service
	
}
