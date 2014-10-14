#
# Manage ebtables
#
class hp_ebtables_rpm::service {

	include hp_ebtables_rpm::install

    service { 'ebtables':
        enable => true,
        ensure => running,
        require => Package['ebtables'],
    }
    
}