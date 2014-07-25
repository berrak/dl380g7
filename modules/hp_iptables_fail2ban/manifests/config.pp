##
## This class manage iptables and fail2ban
## 
class hp_iptables_fail2ban::config ( $puppetserver_hostname = '',
                            $fail2ban_trusted_ip = '',
                            $fail2ban_apache = 'false',
                            $fail2ban_modsec = 'false',
                            $fail2ban_postfix = 'false',
) {

    include hp_iptables_fail2ban

    $mydomain = $::domain

    case $::hostname {
    
        $puppetserver_hostname : {

            file { "/root/bin/fw.${puppetserver_hostname}" :
                 source => "puppet:///modules/hp_iptables_fail2ban/fw.${puppetserver_hostname}",
                  owner => 'root',
                  group => 'root',
                   mode => '0700',
                require => File['/root/bin'],
                 notify => Exec["/bin/sh /root/bin/fw.${puppetserver_hostname}"],
            }

            exec { "/bin/sh /root/bin/fw.${puppetserver_hostname}":
                refreshonly => true,
                     notify => Service['fail2ban'],
            }

            file { '/etc/fail2ban/jail.local':
                   content =>  template( "hp_iptables_fail2ban/jail.local.${puppetserver_hostname}.erb" ),
                     owner => 'root',
                     group => 'root',
                      mode => '0640',
                   require => Package['fail2ban'],
                    notify => Service['fail2ban'],
            }

            file { '/etc/rc.local' :
                source => "puppet:///modules/hp_iptables_fail2ban/rc.local",
                 owner => 'root',
                 group => 'root',
                  mode => '0700',
               require => Package['iptables'],
            }
        
        }

        default: { fail("FAIL: Hostname ${puppetserver_hostname} unknown. Aborting...") }

    }

}
