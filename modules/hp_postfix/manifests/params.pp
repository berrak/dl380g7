#
# Manage postfix module parameters.
#
class hp_postfix::params {

    # The file location were all preseed files are stored.
    # In this case the '{server|satellite}.postfix.preseed' file.
    
    $server_preseedfilepath = "/etc/puppet/files/server.postfix.preseed"
    $satellite_preseedfilepath = "/etc/puppet/files/satellite.postfix.preseed"


    # internal sub domains the mail server should use smtp transport for
    $my_subdomain_one = ''




}
