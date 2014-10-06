##
## This class manage disk status med S.M.A.R.T.
##
class hp_smartmontools::install {

    package { "smartmontools" :
               ensure => present,
        allow_virtual => true,
    }

}
