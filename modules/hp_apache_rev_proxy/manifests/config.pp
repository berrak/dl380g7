#
# Manage apache2 reverse proxy for NAT VM's
#
class hp_apache_rev_proxy::config {


    
    #file { '/etc/apache2/conf.d/security':
    #     source => "puppet:///modules/hp_apache_rev_proxy/security",    
    #      owner => 'root',
    #      group => 'root',
    #    require => Class["hp_apache_rev_proxy::install"],
    #    notify => Service["apache2"],
    #}
 
}